import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedThemeMode = AdaptiveThemeMode.values[prefs.getInt('themeMode') ?? 0];
  runApp(
    AdaptiveTheme(light: ThemeData.light(useMaterial3: true),
        dark: ThemeData.dark(useMaterial3: true),
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          home: const SplashScreen(),
        ),),
  );
}
void saveThemeMode(AdaptiveThemeMode themeMode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('themeMode', themeMode.index);
}

