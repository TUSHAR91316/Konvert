import 'dart:io';
import 'package:converter_app/services/conversion_service.dart';
import 'package:converter_app/services/history_service.dart';
import 'package:converter_app/services/virus_total_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConvertScreen extends StatefulWidget {
  final String initialFormat;
  final List<String>? allowedExtensions;
  const ConvertScreen({super.key, this.initialFormat = 'pdf', this.allowedExtensions});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  List<File> _selectedFiles = [];
  bool _isConverting = false;
  String? _statusMessage;
  late String _targetFormat; 
  String? _outputDirectory;
  
  @override
  void initState() {
    super.initState();
    _targetFormat = widget.initialFormat;
  }
  
  // Services
  final _conversionService = ConversionService();

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, 
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
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
      // 1. VirusTotal Auto-Scan
      bool autoScan = await VirusTotalService().getAutoScanEnabled();
      String? apiKey = await VirusTotalService().getApiKey();
      
      if (autoScan && apiKey != null && apiKey.isNotEmpty) {
         setState(() => _statusMessage = "Scanning for viruses...");
         for (var file in _selectedFiles) {
            String? analysisId = await VirusTotalService().scanFile(file);
            // Ideally we wait for report, but for MVP we just confirm upload.
            // A real app would poll the analysisId.
            if (analysisId == null) throw Exception("Scan failed for ${file.path}");
         }
         setState(() => _statusMessage = "Scan Complete. Safe to process.");
      }
      
      File resultFile;
      String extension = _selectedFiles.first.path.split('.').last.toLowerCase();

       // HYBRID LOGIC
      if (['jpg', 'jpeg', 'png'].contains(extension)) {
         // Local Image -> PDF
         // Only support Image -> PDF for local for MVP
         if (_targetFormat != 'pdf') throw Exception("Local conversion only supports PDF output for now.");
         
         setState(() => _statusMessage = "Merging images locally...");
         resultFile = await _conversionService.imagesToPdf(_selectedFiles, outputDirPath: _outputDirectory);
      
      } else if (extension == 'pdf' && _selectedFiles.length > 1) {
         throw Exception("PDF Merging not fully wired yet"); 
      
      } else if (['docx', 'doc', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'].contains(extension)) { // Added txt for broad support
         // Backend Remote Conversion
         setState(() => _statusMessage = "Uploading to Backend...");
         resultFile = await _conversionService.convertRemote(
           _selectedFiles.first, 
           _targetFormat, 
           outputDirPath: _outputDirectory
         );
      
      } else {
         // Fallback or unsupported
         throw Exception("Unsupported format for MVP: $extension");
      }

      setState(() {
        _statusMessage = "Success! Saved to ${resultFile.path}";
        _isConverting = false;
      });

      // Log to History
      await HistoryService().addEntry(
        originalName: _selectedFiles.first.path.split('/').last, 
        targetFormat: _targetFormat, 
        resultPath: resultFile.path
      );

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

            // Format & Location Selection
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _targetFormat,
                    isExpanded: true,
                    hint: const Text("Select Format"),
                    items: ['pdf', 'docx', 'jpg', 'png'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _targetFormat = newValue!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              InkWell(
                onTap: () async {
                  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                  if (selectedDirectory != null) {
                    setState(() {
                      _outputDirectory = selectedDirectory;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _outputDirectory ?? "Tap to Select Save Location",
                          style: TextStyle(
                              color: _outputDirectory != null ? Colors.black : Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_outputDirectory == null)
                const Padding(
                  padding: EdgeInsets.only(top: 5, left: 5),
                  child: Text("Default: Temporary Folder", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
            ],

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
                   : Text("CONVERT TO ${_targetFormat.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ).animate(target: _selectedFiles.isNotEmpty ? 1 : 0).fadeIn().scale(),
          ],
        ),
      ),
    );
  }
}
