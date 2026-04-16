import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy for Konvert',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Last updated: ${'14th April 2026'}\n\n'
                'Welcome to Konvert! We value your privacy and are committed to protecting your personal data. '
                'This Privacy Policy explains how we collect, use, and share information about you when you use our app.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              Text(
                '1. Information We Collect',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Account Information: When you sign up via Email or Google Sign-In, we collect your name and email address.\n'
                '• Files and Content: To provide conversion and scanning features, the files you upload are temporarily sent to our backend servers and third-party services (like VirusTotal).\n'
                '• App Usage Data: Anonymous usage data to improve user experience.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              Text(
                '2. How We Use Your Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• To authenticate your account securely.\n'
                '• To convert and compress your files.\n'
                '• To scan files for malicious content if enabled.\n'
                '• We do NOT permanently store your files. They are automatically deleted from our servers shortly after processing.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              Text(
                '3. Sharing Your Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We do not sell your data. Your files are only shared temporarily with trusted backend services (Google Cloud Run / VirusTotal API) strictly for the purpose of completing your requested task.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              Text(
                '4. Contact Us',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'If you have any questions or concerns about this privacy policy, please contact us at our support email.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
