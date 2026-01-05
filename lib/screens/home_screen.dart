import 'package:converter_app/screens/compress_image_screen.dart';
import 'package:converter_app/screens/convert_screen.dart';
import 'package:converter_app/screens/history_screen.dart';
import 'package:converter_app/screens/settings_screen.dart';
import 'package:converter_app/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:converter_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:converter_app/main.dart';

import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
     super.initState();
     _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // For Android 11+ (API 30+)
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    
    // For older Android versions or if manage storage is not applicable
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konvert Dashboard'),
        actions: [
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              if (themeNotifier.value == ThemeMode.light) {
                themeNotifier.value = ThemeMode.dark;
              } else {
                themeNotifier.value = ThemeMode.light;
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "Guest User"),
              accountEmail: Text(user?.email ?? "Sign in to sync history"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/final_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            const Divider(),
            if (user == null)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Sign In'),
                onTap: () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const SignInScreen()),
                        (Route<dynamic> route) => false);
                  }
                },
              ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             const Text(
              "Convert File",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // CONVERSION GRID
            GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75,
                children: [
                   _buildGridCard(context, "Images to PDF", "JPG, PNG, WEBP, HEIC", Icons.image, Colors.purple, 'pdf', ['jpg', 'jpeg', 'png', 'webp', 'heic'], 100),
                   _buildGridCard(context, "Word to PDF", "DOC, DOCX", Icons.description, Colors.blue, 'pdf', ['doc', 'docx'], 200),
                   _buildGridCard(context, "Excel to PDF", "XLS, XLSX", Icons.table_chart, Colors.green, 'pdf', ['xls', 'xlsx'], 300),
                   _buildGridCard(context, "PPT to PDF", "PPT, PPTX", Icons.slideshow, Colors.orange, 'pdf', ['ppt', 'pptx'], 400),
                   _buildGridCard(context, "Docs to PDF", "TXT, RTF, HTML", Icons.article, Colors.teal, 'pdf', ['txt', 'rtf', 'html', 'odt'], 500),
                ],
            ),
            const SizedBox(height: 30),

            const Text(
              "Compression Tools",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 20),
            
            GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75,
                children: [
                   _buildCompressionCard(context, "Compress Image", "Reduce size (JPG, PNG)", Icons.compress, Colors.pink, 100),
                   // Placeholder for Docs
                   _buildCompressionCard(context, "Shrink Docs", "Coming Soon (PDF)", Icons.picture_as_pdf, Colors.blueGrey, 200, onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document Compression coming next!")));
                   }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String format, List<String> extensions, int delay) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ConvertScreen(initialFormat: format, allowedExtensions: extensions)));
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              subtitle, 
              style: TextStyle(fontSize: 10, color: Colors.grey[700]), 
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompressionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, int delay, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        if (title == "Compress Image") {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const CompressImageScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              subtitle, 
              style: TextStyle(fontSize: 10, color: Colors.grey[700]), 
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
