import 'dart:io';
import 'package:flutter/material.dart';
import 'package:converter_app/services/history_service.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _historyService.getHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    await _historyService.clearHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversion History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Clear History?"),
                  content: const Text("This cannot be undone."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                    TextButton(onPressed: () {
                      Navigator.pop(ctx);
                      _clearHistory();
                    }, child: const Text("Clear", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text("No history yet", style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final date = DateTime.parse(item['timestamp']);
                    final formattedDate = DateFormat('MMM d, y • h:mm a').format(date);
                    final File resultFile = File(item['resultPath']);
                    final bool exists = resultFile.existsSync();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: exists ? Colors.blueAccent.withValues(alpha: 0.1) : Colors.grey.withValues(alpha:0.1),
                        child: Icon(
                          Icons.description, 
                          color: exists ? Colors.blueAccent : Colors.grey
                        ),
                      ),
                      title: Text(item['originalName']),
                      subtitle: Text("$formattedDate • ${item['targetFormat'].toUpperCase()}"),
                      trailing: exists 
                        ? const Icon(Icons.arrow_forward_ios, size: 16)
                        : const Text("Deleted", style: TextStyle(color: Colors.red, fontSize: 12)),
                      onTap: exists 
                          ? () => OpenFile.open(item['resultPath'])
                          : null,
                    );
                  },
                ),
    );
  }
}
