import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF39B5FF),
  onPrimary: Color(0xFF003546), // Changed for better contrast
  secondary: Color(0xFF021BCC),
  onSecondary: Color(0xFF00363D),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  surface: Color(0xFFF8FDFF),
  onSurface: Color(0xFF001F25),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF013991),
  onPrimary: Color(0xFF003546),
  secondary: Color(0xFF7AF4E5),
  onSecondary: Color(0xFF003732),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  surface: Color(0xFF001F25),
  onSurface: Color(0xFFA6EEFF),
  shadow: Color(0xFF000000),
  outline: Color(0xFF8A9296),
);

ThemeData lightmode = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(lightColorScheme.primary),
      foregroundColor: WidgetStateProperty.all(lightColorScheme.onPrimary),
      elevation: WidgetStateProperty.all<double>(5.0),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 18.0,
        ),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    )
  ),
);

ThemeData darkmode = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(darkColorScheme.primary),
      foregroundColor: WidgetStateProperty.all(darkColorScheme.onPrimary),
      elevation: WidgetStateProperty.all<double>(5.0),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 18.0,
        ),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    )
  ),
);
