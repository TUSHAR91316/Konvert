import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class ConversionService {
  final Dio _dio = Dio();
  
  // Replace with your local IP when testing on device (e.g., 192.168.1.x:8000)
  // Or usage '10.0.2.2' for Android Emulator
  static const String _backendUrl = 'http://10.0.2.2:8000'; 

  // --- LOCAL CONVERSIONS ---

  Future<File> imagesToPdf(List<File> images) async {
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

    return await _savePdf(pdf, "images_converted");
  }

  // Helper to save PDF
  Future<File> _savePdf(pw.Document pdf, String baseName) async {
    final outputDir = await getTemporaryDirectory();
    final file = File("${outputDir.path}/${baseName}_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // --- REMOTE CONVERSIONS (Backend) ---

  Future<File> convertRemote(File file, String targetFormat) async {
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

      final outputDir = await getTemporaryDirectory();
      final outputFile = File("${outputDir.path}/converted_${DateTime.now().millisecondsSinceEpoch}.$targetFormat");
      await outputFile.writeAsBytes(response.data);
      return outputFile;

    } on DioException catch (e) {
      throw Exception("Remote Conversion Failed: ${e.message}");
    }
  }
}
