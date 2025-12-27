import 'package:converter_app/firebase_options.dart';
import 'package:converter_app/screens/welcome_screen.dart';
import 'package:converter_app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:converter_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Konvert',
          theme: lightmode,
          darkTheme: darkmode,
          themeMode: mode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
