import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Required for FileImage

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class ConversionService {
  final Dio _dio = Dio();
  
  // Production Backend (Google Cloud Run)
  static const String _backendUrl = 'https://converter-app-117081560792.europe-west1.run.app'; 

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
      throw Exception("Remote Conversion Failed: ${e.message}");
    }
  }
}
