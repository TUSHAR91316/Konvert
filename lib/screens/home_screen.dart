import 'package:converter_app/screens/convert_screen.dart';
import 'package:converter_app/screens/history_screen.dart';
import 'package:converter_app/screens/settings_screen.dart';
import 'package:converter_app/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:converter_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konvert Dashboard'),
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
                child: Text(
                  (user?.displayName ?? "G")[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40.0),
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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
              "Convert File",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildGridCard(context, "Images to PDF", "JPG, PNG, WEBP, HEIC", Icons.image, Colors.purple, 'pdf', ['jpg', 'jpeg', 'png', 'webp', 'heic'], 100),
                  _buildGridCard(context, "Word to PDF", "DOC, DOCX", Icons.description, Colors.blue, 'pdf', ['doc', 'docx'], 200),
                  _buildGridCard(context, "Excel to PDF", "XLS, XLSX", Icons.table_chart, Colors.green, 'pdf', ['xls', 'xlsx'], 300),
                  _buildGridCard(context, "PPT to PDF", "PPT, PPTX", Icons.slideshow, Colors.orange, 'pdf', ['ppt', 'pptx'], 400),
                  _buildGridCard(context, "Docs to PDF", "TXT, RTF, HTML", Icons.article, Colors.teal, 'pdf', ['txt', 'rtf', 'html', 'odt'], 500),
                ],
              ),
            ),
          ],
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 5),
            Text(
              subtitle, 
              style: TextStyle(fontSize: 10, color: Colors.grey[700]), 
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().scale();
  }
}
