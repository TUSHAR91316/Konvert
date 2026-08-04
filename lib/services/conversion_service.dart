import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Required for FileImage

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

import 'package:converter_app/constants/api_constants.dart';
import 'package:converter_app/services/config_service.dart';

class ConversionService {
  final Dio _dio;
  final ConfigService _configService;

  ConversionService({Dio? dio, ConfigService? configService})
      : _dio = dio ?? Dio(
          BaseOptions(
            connectTimeout: ApiConstants.connectTimeout,
            sendTimeout: ApiConstants.sendTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
          ),
        ),
        _configService = configService ?? ConfigService();

  // --- LOCAL CONVERSIONS ---

  Future<File> imagesToPdf(List<File> images, {String? outputDirPath}) async {
    final pdf = pw.Document();

    for (var imgFile in images) {
      final image = await flutterImageProvider(FileImage(imgFile));
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ));
    }

    return await _savePdf(pdf, "images_converted", outputDirPath: outputDirPath);
  }

  /// Merges multiple PDF files into a single PDF.
  ///
  /// Strategy: Try the backend `/merge-pdfs` endpoint first (lossless, server-side).
  /// If the backend is offline or unreachable, falls back to a fully **offline**
  /// merge using the Dart `pdf` package — no Docker required.
  Future<File> mergePdfs(List<File> pdfs, {String? outputDirPath}) async {
    if (pdfs.isEmpty) throw Exception('No PDF files provided for merging.');
    if (pdfs.length == 1) {
      final outputDir = outputDirPath != null
          ? Directory(outputDirPath)
          : await getTemporaryDirectory();
      final out = File('${outputDir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await pdfs.first.copy(out.path);
      return out;
    }

    // ── Try backend first ──────────────────────────────────────────────────────
    try {
      final String backendUrl = await _configService.getBackendUrl();

      // Quick health-check so we don't waste time uploading files to an offline server
      await _dio.get(
        '$backendUrl/health',
        options: Options(
          sendTimeout: ApiConstants.healthCheckTimeout,
          receiveTimeout: ApiConstants.healthCheckTimeout,
        ),
      );

      final Directory outputDir = outputDirPath != null
          ? Directory(outputDirPath)
          : await getTemporaryDirectory();
      final outputFile = File('${outputDir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf');

      final formData = FormData.fromMap({
        'files': [
          for (final pdf in pdfs)
            await MultipartFile.fromFile(
              pdf.path,
              filename: pdf.path.split('/').last,
            ),
        ],
      });

      await _dio.download(
        '$backendUrl/merge-pdfs',
        outputFile.path,
        data: formData,
        options: Options(method: 'POST'),
      );

      // Validate downloaded file is a real PDF (not a JSON error)
      if (outputFile.existsSync() &&
          outputFile.lengthSync() > ApiConstants.maxJsonErrorPayloadBytes) {
        return outputFile;
      }
      // Small response — might be a JSON error, fall through to offline
      if (outputFile.existsSync()) outputFile.deleteSync();
    } on DioException catch (e) {
      // Backend offline or unreachable — fall through to offline merge
      if (e.type != DioExceptionType.connectionError &&
          e.type != DioExceptionType.connectionTimeout) {
        rethrow; // Unexpected error — bubble up
      }
    } catch (_) {
      // Any other failure (health check) — fall through to offline merge
    }

    // ── Offline fallback using Dart `pdf` package ─────────────────────────────
    return _mergePdfsOffline(pdfs, outputDirPath: outputDirPath);
  }

  /// Merges PDFs entirely on-device using the Dart `pdf` package.
  ///
  /// Note: This re-renders each page as a rasterized image (300 DPI) since pure
  /// Dart PDF parsing (without native code) cannot clone PDF page streams
  /// losslessly. Text remains selectable if the original PDF is vector-based
  /// and the device renders it correctly via the `printing` package.
  Future<File> _mergePdfsOffline(List<File> pdfs, {String? outputDirPath}) async {
    final mergedDoc = pw.Document();

    for (final pdfFile in pdfs) {
      // Load PDF pages as rasterized images via the `printing` package
      final Uint8List pdfBytes = await pdfFile.readAsBytes();
      await for (final page in Printing.raster(pdfBytes, dpi: 150)) {
        final image = await page.toPng();
        final pdfImage = pw.MemoryImage(image);
        mergedDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(page.width.toDouble(), page.height.toDouble()),
            build: (pw.Context ctx) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            ),
          ),
        );
      }
    }

    return await _savePdf(mergedDoc, 'merged', outputDirPath: outputDirPath);
  }

  // Helper to save PDF
  Future<File> _savePdf(pw.Document pdf, String baseName, {String? outputDirPath}) async {
    final Directory outputDir;
    if (outputDirPath != null) {
      outputDir = Directory(outputDirPath);
    } else {
      outputDir = await getTemporaryDirectory();
    }
    
    final file = File("${outputDir.path}/${baseName}_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // --- REMOTE CONVERSIONS (Backend) ---

  Future<File> convertRemote(File file, String targetFormat, {String? outputDirPath}) async {
    String fileName = file.path.split('/').last;
    
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final Directory outputDir;
    if (outputDirPath != null) {
      outputDir = Directory(outputDirPath);
    } else {
      outputDir = await getTemporaryDirectory();
    }

    final outputFile = File("${outputDir.path}/converted_${DateTime.now().millisecondsSinceEpoch}.$targetFormat");

    try {
      final String dynamicBackendUrl = await _configService.getBackendUrl();
      await _dio.download(
        '$dynamicBackendUrl/convert',
        outputFile.path,
        data: formData,
        queryParameters: {'target_format': targetFormat},
        options: Options(method: 'POST'),
      );
      
      return outputFile;

    } on DioException catch (e) {
      // Check if dio.download wrote the JSON error to the output file
      if (outputFile.existsSync()) {
        try {
          if (outputFile.lengthSync() < ApiConstants.maxJsonErrorPayloadBytes) {
            String errorString = outputFile.readAsStringSync();
            final errorJson = jsonDecode(errorString);
            outputFile.deleteSync();
            throw ConversionException(
              code: errorJson['error_code'] ?? 'UNKNOWN',
              message: errorJson['message'] ?? e.message ?? 'Unknown error',
              resolution: errorJson['resolution'] ?? 'Please try again.',
            );
          }
        } catch (parseError) {
          if (parseError is ConversionException) rethrow;
          // Fallback if parsing fails
        }
        outputFile.deleteSync(); // always clean up failed download
      }

      final statusCode = e.response?.statusCode;
      if (statusCode == 503) {
        throw Exception(
          "Conversion server is temporarily unavailable (503). "
          "It may be starting up — please wait a moment and try again.",
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          "Conversion timed out. The file may be too large or the server is busy. "
          "Please try again.",
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          "Could not reach the conversion server. "
          "Please check your internet connection.",
        );
      } else {
        throw Exception(
          "Remote Conversion Failed (${statusCode ?? 'unknown'}): ${e.message}",
        );
      }
    }
  }
}

class ConversionException implements Exception {
  final String code;
  final String message;
  final String resolution;

  ConversionException({
    required this.code,
    required this.message,
    required this.resolution,
  });

  @override
  String toString() => "[$code] $message\nResolution: $resolution";
}
