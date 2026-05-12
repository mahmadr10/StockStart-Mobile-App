// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool    _loading = false;
  bool    _obscure = true;
  String? _error;

  // ── LOGIN LOGIC ────────────────────────────────────────────
  Future<void> _login() async {
    final u = _userCtrl.text.trim();
    final p = _passCtrl.text.trim();

    if (u.isEmpty || p.isEmpty) {
      setState(() => _error = 'Please enter both username and password.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final err = await DatabaseService.login(u, p);

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ── HEADER ─────────────────────────────────────
              const Text(
                'Welcome Back 👋',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Log in to your StockStart account',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 36),

              // ── USERNAME ────────────────────────────────────
              _label('Username'),
              const SizedBox(height: 8),
              TextField(
                controller: _userCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                textInputAction: TextInputAction.next,
                decoration: _inputDec(
                  hint: 'Enter your username',
                  icon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(height: 18),

              // ── PASSWORD ────────────────────────────────────
              _label('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: AppTheme.textPrimary),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                decoration: _inputDec(
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── ERROR ───────────────────────────────────────
              if (_error != null) _errorBox(_error!),

              const SizedBox(height: 8),

              // ── BUTTON ──────────────────────────────────────
              _loading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primary))
                  : ElevatedButton(
                onPressed: _login,
                child: const Text('Log In'),
              ),

              const SizedBox(height: 22),

              // ── SIGN-UP LINK ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/signup'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      color: AppTheme.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );

  InputDecoration _inputDec({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        suffixIcon: suffix,
      );

  Widget _errorBox(String msg) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.danger.withOpacity(0.10),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.danger.withOpacity(0.30)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline,
            color: AppTheme.danger, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            msg,
            style: const TextStyle(
                color: AppTheme.danger, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}