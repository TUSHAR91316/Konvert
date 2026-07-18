import 'package:converter_app/firebase_options.dart';
import 'package:converter_app/theme/theme.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:converter_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
final accentColorNotifier = ValueNotifier<Color>(const Color(0xFF4F46E5));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const storage = FlutterSecureStorage();
  final savedColor = await storage.read(key: 'accent_color');
  if (savedColor != null) {
    final value = int.tryParse(savedColor);
    if (value != null) {
      final color = Color(value);
      KColors.primary = color;
      accentColorNotifier.value = color;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        return ValueListenableBuilder<Color>(
          valueListenable: accentColorNotifier,
          builder: (context, primaryColor, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Konvert',
              theme: lightmode,
              darkTheme: darkmode,
              themeMode: mode,
              home: const HomeScreen(),
              // ── Global text scale guard ──
              // Prevents system-level "large font" accessibility settings from
              // overflowing fixed-height UI containers (buttons, cards, etc.).
              // Caps at 1.2× so readability is still improved, just not broken.
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context).textScaler.clamp(
                    minScaleFactor: 0.85,
                    maxScaleFactor: 1.2,
                  ),
                ),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
