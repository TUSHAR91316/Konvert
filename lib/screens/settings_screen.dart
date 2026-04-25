import 'package:converter_app/services/virus_total_service.dart';
import 'package:converter_app/services/config_service.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _backendUrlController = TextEditingController();
  final _vtService = VirusTotalService();
  final _configService = ConfigService();
  bool _isLoading = true;
  bool _autoScanEnabled = false;
  String _appVersion = "Loading...";

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
    
    String url = await _configService.getBackendUrl();
    _backendUrlController.text = url;
    
    bool autoScan = await _vtService.getAutoScanEnabled();
    _autoScanEnabled = autoScan;

    // Load app version
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
    } catch (e) {
      _appVersion = "1.6.2";
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _saveKey() async {
    await _vtService.setApiKey(_apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Key Saved!")));
    }
  }

  Future<void> _saveBackendUrl() async {
    await _configService.setBackendUrl(_backendUrlController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backend URL Saved!")));
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
                  const Text("Server Configuration", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Connect to your own backend server. Use ngrok, Cloudflare Tunnel, or any tunneling service to expose your local FastAPI server. This URL overrides the default configuration for document conversions."),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _backendUrlController,
                    decoration: const InputDecoration(
                      labelText: "Backend URL",
                      hintText: "https://abc123.ngrok-free.app or https://your-tunnel.cloudflare.com",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveBackendUrl,
                      child: const Text("Save URL"),
                    ),
                  ),

                  const SizedBox(height: 40),

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
                  Center(child: Text("Version $_appVersion (Hybrid MVP)", style: const TextStyle(color: Colors.grey))),
                ],
              ),
            ),
    );
  }
}
