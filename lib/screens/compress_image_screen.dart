import 'dart:io';
import 'package:converter_app/services/compression_service.dart';
import 'package:converter_app/services/history_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CompressImageScreen extends StatefulWidget {
  const CompressImageScreen({super.key});

  @override
  State<CompressImageScreen> createState() => _CompressImageScreenState();
}

class _CompressImageScreenState extends State<CompressImageScreen> {
  final _compressionService = CompressionService();
  File? _selectedFile;
  File? _resultFile;
  bool _isCompressing = false;
  String? _statusMessage;
  String? _outputDirectory;

  // Mode: 0 = Percentage, 1 = Target Size
  int _mode = 0;

  Future<void> _pickDirectory() async {
    String? dir = await FilePicker.platform.getDirectoryPath();
    if (dir != null) {
      setState(() => _outputDirectory = dir);
    }
  }

  // ... (inside _processCompression) ...
      if (compressed == null) throw Exception("Compression failed");

      // Save to Output Directory if Selected
      if (_outputDirectory != null) {
         final fileName = "compressed_${p.basename(_selectedFile!.path)}";
         final newPath = p.join(_outputDirectory!, fileName);
         _resultFile = await compressed.copy(newPath);
      } else {
         _resultFile = compressed;
      }
      
      // Calculate savings ... 

  int _mode = 0;

  // Percentage Mode
  double _quality = 80;

  // Target Size Mode
  final _sizeController = TextEditingController();
  String _sizeUnit = 'KB'; // KB or MB

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _resultFile = null;
        _statusMessage = null;
      });
    }
  }

  Future<void> _processCompression() async {
    if (_selectedFile == null) return;

    setState(() {
      _isCompressing = true;
      _statusMessage = "Compressing...";
      _resultFile = null;
    });

    try {
      File? compressed;
      if (_mode == 0) {
        // Percentage
        compressed = await _compressionService.compressImagePercentage(_selectedFile!, _quality.toInt());
      } else {
        // Target Size
        final inputVal = double.tryParse(_sizeController.text);
        if (inputVal == null || inputVal <= 0) throw Exception("Invalid size");
        
        int targetBytes = _sizeUnit == 'MB' 
            ? (inputVal * 1024 * 1024).toInt() 
            : (inputVal * 1024).toInt();
            
        compressed = await _compressionService.compressImageToSize(_selectedFile!, targetBytes);
      }

      if (compressed == null) throw Exception("Compression failed");

      // Save to Output Directory if Selected
      if (_outputDirectory != null) {
         final fileName = "compressed_${p.basename(_selectedFile!.path)}";
         final newPath = p.join(_outputDirectory!, fileName);
         _resultFile = await compressed.copy(newPath);
      } else {
         _resultFile = compressed;
      }
      
      // Calculate savings
      int originalSize = await _selectedFile!.length();
      int newSize = await _resultFile!.length();
      double saved = (originalSize - newSize) / originalSize * 100;
      
      String sizeStr = _formatSize(newSize);
      String loc = _outputDirectory != null ? "\nSaved to: ${p.basename(_resultFile!.path)}" : "\nSaved to Temp";

      setState(() {
        _statusMessage = "Success! Size: $sizeStr$loc\n(Reduced by ${saved.toStringAsFixed(1)}%)";
        _isCompressing = false;
      });

      setState(() {
        _statusMessage = "Success! Saved $sizeStr\n(Reduced by ${saved.toStringAsFixed(1)}%)";
        _isCompressing = false;
      });

    } catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.toString()}";
        _isCompressing = false;
      });
    }
  }
  
  String _formatSize(int bytes) {
      double kb = bytes / 1024;
      double mb = kb / 1024;
      return mb >= 1 ? "${mb.toStringAsFixed(2)} MB" : "${kb.toStringAsFixed(0)} KB";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Compress Image")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Picker
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedFile != null) ...[
                      const Icon(Icons.check_circle, size: 60, color: Colors.green),
                      const SizedBox(height: 10),
                      Text("Selected: ${p.basename(_selectedFile!.path)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      FutureBuilder<int>(
                        future: _selectedFile!.length(), 
                        builder: (c, s) => Text(s.hasData ? _formatSize(s.data!) : "...", style: const TextStyle(color: Colors.grey))
                      ),
                    ] else ...[
                      const Icon(Icons.add_photo_alternate, size: 60, color: Colors.purple),
                      const SizedBox(height: 10),
                      const Text("Tap to Pick Image", style: TextStyle(fontSize: 18, color: Colors.purple)),
                    ]
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (_selectedFile != null) ...[
                const Text("Compression Mode", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(child: RadioListTile(
                      title: const Text("Percentage"), 
                      value: 0, 
                      groupValue: _mode, 
                      onChanged: (v) => setState(() => _mode = v!),
                      contentPadding: EdgeInsets.zero,
                    )),
                    Expanded(child: RadioListTile(
                      title: const Text("Target Size"), 
                      value: 1, 
                      groupValue: _mode, 
                      onChanged: (v) => setState(() => _mode = v!),
                      contentPadding: EdgeInsets.zero,
                    )),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                if (_mode == 0) ...[
                   // Slider
                   Text("Quality: ${_quality.toInt()}%"),
                   Slider(
                     value: _quality, 
                     min: 5, 
                     max: 100, 
                     divisions: 19,
                     label: "${_quality.toInt()}%",
                     onChanged: (v) => setState(() => _quality = v),
                   ),
                ] else ...[
                   // Target Size Inputs
                   Row(
                     children: [
                       Expanded(
                         flex: 2,
                         child: TextField(
                           controller: _sizeController,
                           keyboardType: TextInputType.number,
                           decoration: const InputDecoration(
                             labelText: "Size",
                             border: OutlineInputBorder(),
                           ),
                         ),
                       ),
                       const SizedBox(width: 10),
                       Expanded(
                         flex: 1,
                         child: DropdownButtonFormField<String>(
                           value: _sizeUnit,
                           items: const [
                             DropdownMenuItem(value: 'KB', child: Text('KB')),
                             DropdownMenuItem(value: 'MB', child: Text('MB')),
                           ],
                           onChanged: (v) => setState(() => _sizeUnit = v!),
                           decoration: const InputDecoration(border: OutlineInputBorder()),
                         ),
                       ),
                     ],
                   ),
                ],
                
                const SizedBox(height: 20),

                // Output Directory Selector
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Save Location (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_outputDirectory ?? "Default: Temporary Folder"),
                  trailing: IconButton(
                    icon: const Icon(Icons.folder_open, color: Colors.blue),
                    onPressed: _pickDirectory,
                  ),
                ),

                const SizedBox(height: 20),
                
               if (_isCompressing)
                  Column(
                    children: [
                       const LinearProgressIndicator(),
                       const SizedBox(height: 10),
                       Text(_statusMessage ?? "Processing..."),
                    ],
                  )
               else
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _processCompression,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text("COMPRESS NOW", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
            ],

            if (_resultFile != null && !_isCompressing) 
               Container(
                 margin: const EdgeInsets.only(top: 20),
                 padding: const EdgeInsets.all(15),
                 decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                 child: Column(
                   children: [
                     Text(_statusMessage ?? "Done!", textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 10),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         ElevatedButton.icon(
                           icon: const Icon(Icons.open_in_new),
                           label: const Text("Open"),
                           onPressed: () => OpenFile.open(_resultFile!.path),
                         ),
                         // Add History logic later if needed
                       ],
                     )
                   ],
                 ),
               ).animate().fadeIn().slideY(),
          ],
        ),
      ),
    );
  }
}
