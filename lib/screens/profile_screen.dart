// ============================================================
// FILE: lib/screens/profile_screen.dart
// PURPOSE: SCREEN 6 — Profile & Learning Progress
//          Avatar, Premium badge, Progress bar, Settings
// ============================================================

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Toggle states for settings ──────────────────────────────
  bool _notificationsEnabled = true;
  bool _darkModeEnabled      = false;
  bool _learningReminders    = true;

  // Learning progress (0.0 to 1.0)
  static const double _learningProgress = 0.75;

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
                style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (_) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,

      // ── APP BAR ────────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── PROFILE HEADER ────────────────────────────────
            Center(
              child: Column(
                children: [
                  // Avatar circle
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Ahmad',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Premium badge
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            size: 14, color: AppColors.amber),
                        SizedBox(width: 4),
                        Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Joined 2 years ago',
                    style:
                    TextStyle(fontSize: 12, color: AppColors.greyLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── LEARNING SECTION ──────────────────────────────
            _sectionHeader('Learning'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Learning progress',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dark),
                      ),
                      Text(
                        '${(_learningProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _learningProgress,
                      minHeight: 10,
                      backgroundColor: AppColors.greyBg,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '15 / 20 lessons completed',
                    style:
                    TextStyle(fontSize: 12, color: AppColors.greyLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _settingsTile(
              icon: Icons.alarm_outlined,
              label: 'Learning reminders',
              trailing: Switch(
                value: _learningReminders,
                activeColor: AppColors.green,
                onChanged: (val) =>
                    setState(() => _learningReminders = val),
              ),
            ),
            const SizedBox(height: 20),

            // ── ACCOUNT SECTION ───────────────────────────────
            _sectionHeader('Account'),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: AppColors.green,
                onChanged: (val) =>
                    setState(() => _notificationsEnabled = val),
              ),
            ),
            _settingsTile(
              icon: Icons.dark_mode_outlined,
              label: 'Dark mode',
              trailing: Switch(
                value: _darkModeEnabled,
                activeColor: AppColors.green,
                onChanged: (val) =>
                    setState(() => _darkModeEnabled = val),
              ),
            ),
            _settingsTile(
              icon: Icons.language_outlined,
              label: 'Language',
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('English',
                      style:
                      TextStyle(color: AppColors.grey, fontSize: 14)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: AppColors.greyLight),
                ],
              ),
            ),
            _settingsTile(
              icon: Icons.help_outline_rounded,
              label: 'Help center',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.greyLight),
              onTap: () {},
            ),
            _settingsTile(
              icon: Icons.people_outline_rounded,
              label: 'Invite friends',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.greyLight),
              onTap: () {},
            ),
            _settingsTile(
              icon: Icons.star_outline_rounded,
              label: 'Rate us',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.greyLight),
              onTap: () {},
            ),
            const SizedBox(height: 12),

            // ── LOG OUT ───────────────────────────────────────
            _settingsTile(
              icon: Icons.logout_rounded,
              label: 'Log out',
              labelColor: AppColors.red,
              iconColor: AppColors.red,
              trailing:
              const Icon(Icons.chevron_right, color: AppColors.greyLight),
              onTap: _logout,
            ),
            const SizedBox(height: 24),

            // ── APP VERSION ───────────────────────────────────
            const Center(
              child: Text(
                'StockStart v1.0.0  •  CS-418 Lab 02',
                style: TextStyle(fontSize: 11, color: AppColors.greyLight),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      // ── BOTTOM NAV ─────────────────────────────────────────────
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }

  // ── Helper: section header label ──────────────────────────────
  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
      ),
    );
  }

  // ── Helper: settings row tile ─────────────────────────────────
  Widget _settingsTile({
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
    Color labelColor = AppColors.dark,
    Color iconColor  = AppColors.grey,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
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
                  color: labelColor,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}