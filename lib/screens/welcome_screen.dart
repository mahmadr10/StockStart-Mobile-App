// ============================================================
// FILE: lib/screens/welcome_screen.dart
// PURPOSE: SCREEN 1 — First screen users see.
//          Log In / Sign Up / Continue as Guest buttons.
// ============================================================

import 'package:flutter/material.dart';
import 'package:stockstart/database/database_helper.dart';
import 'package:stockstart/models/stock.dart';
import 'package:stockstart/utils/app_theme.dart';
import 'package:stockstart/widgets/bottom_nav.dart';
import 'package:stockstart/widgets/stock_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(), // Pushes content to vertical center

              // ── LOGO ──────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),

              // ── APP NAME ──────────────────────────────────────
              const Text(
                'StockStart',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),

              // ── TAGLINE ───────────────────────────────────────
              const Text(
                'Learn Stocks the Simple Way',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.grey,
                ),
              ),

              const Spacer(),

              // ── LOG IN BUTTON (filled green) ──────────────────
              ElevatedButton(
                onPressed: () {
                  // Goes to Home (in real app this would check credentials)
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text('Log In'),
              ),
              const SizedBox(height: 12),

              // ── SIGN UP BUTTON (outlined) ─────────────────────
              OutlinedButton(
                onPressed: () {
                  // Goes to Home (in real app this would create account)
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green, width: 2),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16),

              // ── CONTINUE AS GUEST (text link) ─────────────────
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Continue as Guest',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── TERMS TEXT ────────────────────────────────────
              const Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.greyLight),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
