// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _userCtrl    = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confCtrl    = TextEditingController();
  bool    _loading     = false;
  bool    _obscure     = true;
  bool    _obscureConf = true;
  String? _error;

  Future<void> _signUp() async {
    final u  = _userCtrl.text.trim();
    final p  = _passCtrl.text.trim();
    final pc = _confCtrl.text.trim();

    if (u.isEmpty || p.isEmpty || pc.isEmpty) {
      setState(() => _error = 'Please fill in all fields.'); return;
    }
    if (u.length < 3) {
      setState(() => _error = 'Username must be at least 3 characters.'); return;
    }
    if (p.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.'); return;
    }
    if (p != pc) {
      setState(() => _error = 'Passwords do not match.'); return;
    }

    setState(() { _loading = true; _error = null; });
    final err = await DatabaseService.signUp(u, p);
    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Account created! Please log in.'),
        backgroundColor: AppTheme.primary,
      ));
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose(); _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
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
              const Text('Create Account 🚀',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              const SizedBox(height: 6),
              const Text('Join StockStart and start learning',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 36),

              _label('Username'),
              const SizedBox(height: 8),
              TextField(
                controller: _userCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: _inputDec(
                    hint: 'Choose a username',
                    icon: Icons.person_outline_rounded),
              ),
              const SizedBox(height: 18),

              _label('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: _inputDec(
                  hint: 'Min. 6 characters',
                  icon: Icons.lock_outline_rounded,
                  suffix: _eyeBtn(_obscure, () => setState(() => _obscure = !_obscure)),
                ),
              ),
              const SizedBox(height: 18),

              _label('Confirm Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _confCtrl,
                obscureText: _obscureConf,
                style: const TextStyle(color: AppTheme.textPrimary),
                onSubmitted: (_) => _signUp(),
                decoration: _inputDec(
                  hint: 'Re-enter password',
                  icon: Icons.lock_outline_rounded,
                  suffix: _eyeBtn(_obscureConf, () => setState(() => _obscureConf = !_obscureConf)),
                ),
              ),
              const SizedBox(height: 14),

              if (_error != null) _errorBox(_error!),

              const SizedBox(height: 8),
              _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : ElevatedButton(onPressed: _signUp, child: const Text('Create Account')),
              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Log In',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
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

  Widget _label(String t) => Text(t, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600));

  InputDecoration _inputDec({required String hint, required IconData icon, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        suffixIcon: suffix,
      );

  Widget _eyeBtn(bool obscured, VoidCallback onTap) => IconButton(
    icon: Icon(obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary),
    onPressed: onTap,
  );

  Widget _errorBox(String msg) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.danger.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: AppTheme.danger, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(color: AppTheme.danger, fontSize: 13))),
      ],
    ),
  );
}
