import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StockStartApp());
}

class StockStartApp extends StatelessWidget {
  const StockStartApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockStart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}