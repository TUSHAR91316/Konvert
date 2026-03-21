import 'package:converter_app/services/virus_total_service.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _vtService = VirusTotalService();
  bool _isLoading = true;
  bool _autoScanEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    String? key = await _vtService.getApiKey();
    if (key != null) {
      _apiKeyController.text = key;
    }
    bool autoScan = await _vtService.getAutoScanEnabled();
    _autoScanEnabled = autoScan;
    setState(() => _isLoading = false);
  }

  Future<void> _saveKey() async {
    await _vtService.setApiKey(_apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Key Saved!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("VirusTotal Integration", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Enter your VirusTotal API Key to enable scanning before conversion."),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: "API Key",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveKey,
                      child: const Text("Save Key"),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  SwitchListTile(
                    title: const Text("Auto-Scan Files"),
                    subtitle: const Text("Automatically scan files with VirusTotal before converting."),
                    value: _autoScanEnabled,
                    onChanged: (val) {
                      if (val && _apiKeyController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter and save an API Key first!"), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      
                      setState(() => _autoScanEnabled = val);
                      _vtService.setAutoScanEnabled(val);
                    },
                  ),

                  const Spacer(),
                  const Center(child: Text("Version 1.5.0 (Hybrid MVP)", style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
    );
  }
}
