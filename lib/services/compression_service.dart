import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CompressionService {
  
  // Percentage-based compression
  Future<File?> compressImagePercentage(File file, int quality) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, "${DateTime.now().millisecondsSinceEpoch}_compressed${p.extension(file.path)}");

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      // Maintain format if possible, though library handles formats slightly differently.
      // For standard usage, auto-detect works or we force extension.
    );

    return result != null ? File(result.path) : null;
  }

  // Target Size compression (Iterative)
  // targetSize in Bytes
  Future<File?> compressImageToSize(File file, int targetSizeBytes) async {
    int quality = 90;
    int minQuality = 5;
    File? compressedFile;

    // First pass
    compressedFile = await compressImagePercentage(file, quality);

    // Iterative reduction
    while (compressedFile != null && await compressedFile.length() > targetSizeBytes && quality > minQuality) {
      quality -= 10;
      compressedFile = await compressImagePercentage(file, quality);
    }
    
    // Fine-tune if we overshot or undershot significantly (optional optimization)
    // For MVP, simple step-down is sufficient and safe.
    
    return compressedFile;
  }
}
