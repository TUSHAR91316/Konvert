import 'dart:io';
import 'package:converter_app/services/conversion_service.dart';
import 'package:converter_app/services/virus_total_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  List<File> _selectedFiles = [];
  bool _isConverting = false;
  String? _statusMessage;
  
  // Services
  final _conversionService = ConversionService();

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, 
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
        _statusMessage = null; // Reset status
      });
    }
  }

  // Determine conversion strategy
  Future<void> _processConversion() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isConverting = true;
      _statusMessage = "Starting...";
    });

    try {
      // 1. VirusTotal Scan (Optional - User would toggle this in real app, doing auto for demo if key exists)
      // For MVP, we skip strictly enforcing VT to avoid blocking flow if no key.
      
      File resultFile;
      String extension = _selectedFiles.first.path.split('.').last.toLowerCase();

      // HYBRID LOGIC
      if (['jpg', 'jpeg', 'png'].contains(extension)) {
         // Local Image -> PDF
         setState(() => _statusMessage = "Merging images locally...");
         resultFile = await _conversionService.imagesToPdf(_selectedFiles);
      
      } else if (extension == 'pdf' && _selectedFiles.length > 1) {
         // Local PDF Merge (Example - need to implement mergePdfs in service if not already)
         // For now, let's assume single PDF just stays PDF or we merge.
         // Calling a placeholder merge function (needs impl in service)
         // resultFile = await _conversionService.mergePdfs(_selectedFiles);
         throw Exception("PDF Merging not fully wired yet"); 
      
      } else if (['docx', 'doc', 'ppt', 'pptx', 'xls', 'xlsx'].contains(extension)) {
         // Backend Remote Conversion
         setState(() => _statusMessage = "Uploading to Backend...");
         resultFile = await _conversionService.convertRemote(_selectedFiles.first, "pdf");
      
      } else {
         // Fallback or unsupported
         throw Exception("Unsupported format for MVP: $extension");
      }

      setState(() {
        _statusMessage = "Success! Saved to ${resultFile.path}";
        _isConverting = false;
      });

      // Open result
      // await OpenFile.open(resultFile.path); // Needs open_file package

    } catch (e) {
      setState(() {
        _statusMessage = "Error: $e";
        _isConverting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Convert File")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // File Picker Area
            GestureDetector(
              onTap: _pickFiles,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, size: 50, color: Colors.blue),
                    const SizedBox(height: 10),
                    Text(_selectedFiles.isEmpty ? "Tap to select files" : "${_selectedFiles.length} files selected"),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // File List
            if (_selectedFiles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.file_present),
                      title: Text(_selectedFiles[index].path.split('/').last),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedFiles.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

             const SizedBox(height: 20),

             // Status
             if (_statusMessage != null)
               Text(_statusMessage!, style: TextStyle(color: _statusMessage!.startsWith("Error") ? Colors.red : Colors.green)),

             const SizedBox(height: 20),

            // Convert Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isConverting || _selectedFiles.isEmpty) ? null : _processConversion,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: _isConverting 
                   ? const CircularProgressIndicator(color: Colors.white)
                   : const Text("CONVERT NOW", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ).animate(target: _selectedFiles.isNotEmpty ? 1 : 0).fadeIn().scale(),
          ],
        ),
      ),
    );
  }
}
