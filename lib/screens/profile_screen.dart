// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../theme_provider.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _learningReminders    = true;

  static const double _learningProgress = 0.75;

  bool get _darkModeEnabled => ThemeProvider().isDark;

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
        const Text('Are you sure you want to log out of StockStart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (_) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Log Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PROFILE HEADER ──
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ahmad',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star_rounded,
                            size: 14, color: AppColors.amber),
                        SizedBox(width: 4),
                        Text('Premium',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.amber)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Joined 2 years ago',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── LEARNING SECTION ──
            _sectionHeader('Learning'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Learning progress',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary)),
                      Text(
                        '${(_learningProgress * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _learningProgress,
                      minHeight: 10,
                      backgroundColor: AppTheme.border,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('15 / 20 lessons completed',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _settingsTile(
              icon: Icons.alarm_outlined,
              label: 'Learning reminders',
              trailing: Switch(
                value: _learningReminders,
                activeColor: AppTheme.primary,
                onChanged: (val) =>
                    setState(() => _learningReminders = val),
              ),
            ),
            const SizedBox(height: 20),

            // ── ACCOUNT SECTION ──
            _sectionHeader('Account'),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: AppTheme.primary,
                onChanged: (val) =>
                    setState(() => _notificationsEnabled = val),
              ),
            ),
            _settingsTile(
              icon: Icons.dark_mode_outlined,
              label: 'Dark mode',
              trailing: Switch(
                value: _darkModeEnabled,
                activeColor: AppTheme.primary,
                onChanged: (val) {
                  StockStartApp.of(context)?.toggleTheme(val);
                  setState(() {});
                },
              ),
            ),
            _settingsTile(
              icon: Icons.language_outlined,
              label: 'Language',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('English',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary),
                ],
              ),
            ),
            _settingsTile(
              icon: Icons.help_outline_rounded,
              label: 'Help center',
              trailing: const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary),
              onTap: () {},
            ),
            _settingsTile(
              icon: Icons.people_outline_rounded,
              label: 'Invite friends',
              trailing: const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary),
              onTap: () {},
            ),
            _settingsTile(
              icon: Icons.star_outline_rounded,
              label: 'Rate us',
              trailing: const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary),
              onTap: () {},
            ),
            const SizedBox(height: 12),

            // ── LOG OUT ──
            _settingsTile(
              icon: Icons.logout_rounded,
              label: 'Log out',
              labelColor: AppTheme.danger,
              iconColor: AppTheme.danger,
              trailing: const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary),
              onTap: _logout,
            ),
            const SizedBox(height: 24),

            const Center(
              child: Text(
                'StockStart v1.0.0  •  CS-418 Lab 02',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
    title,
    style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary),
  );

  Widget _settingsTile({
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
    Color labelColor = AppTheme.textPrimary,
    Color iconColor  = AppTheme.textSecondary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: labelColor),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}