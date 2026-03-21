import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Required for FileImage

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConversionService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(minutes: 1),
      sendTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );
  
  // Production Backend (Google Cloud Run)
  static final String _backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080'; 

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

    try {
      final response = await _dio.post(
        '$_backendUrl/convert',
        data: formData,
        queryParameters: {'target_format': targetFormat},
        options: Options(
          responseType: ResponseType.bytes, // Important for downloading file
        ),
      );

      final Directory outputDir;
      if (outputDirPath != null) {
        outputDir = Directory(outputDirPath);
      } else {
        outputDir = await getTemporaryDirectory();
      }

      final outputFile = File("${outputDir.path}/converted_${DateTime.now().millisecondsSinceEpoch}.$targetFormat");
      await outputFile.writeAsBytes(response.data);
      return outputFile;

    } on DioException catch (e) {
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
