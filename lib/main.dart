// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/app_theme.dart';
import 'theme_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const StockStartApp());
}

class StockStartApp extends StatefulWidget {
  const StockStartApp({super.key});
  static _StockStartAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_StockStartAppState>();

  @override
  State<StockStartApp> createState() => _StockStartAppState();
}

class _StockStartAppState extends State<StockStartApp> {
  final _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() => setState(() {}));
  }

  void toggleTheme(bool isDark) => _themeProvider.setDark(isDark);
  bool get isDark => _themeProvider.isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockStart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/':       (_) => const WelcomeScreen(),
        '/login':  (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home':   (_) => const MainShell(),
      },
    );
  }
}