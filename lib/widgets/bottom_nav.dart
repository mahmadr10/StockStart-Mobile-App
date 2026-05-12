// ============================================================
// FILE: lib/widgets/bottom_nav.dart
// PURPOSE: The bottom navigation bar shared across all screens
// ============================================================

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex; // 0=Home, 1=Watchlist, 2=Learn, 3=Alerts, 4=Profile

  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
<<<<<<< HEAD
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textSecondary,
      backgroundColor: AppTheme.surface,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        if (index == currentIndex) return;
=======
      selectedItemColor: AppColors.green,
      unselectedItemColor: AppColors.greyLight,
      backgroundColor: AppColors.white,
      type: BottomNavigationBarType.fixed, // shows all labels
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        if (index == currentIndex) return; // Already on this tab
>>>>>>> a1fe5b7592d17b8a4d105c3888380dcb912d232d
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
            break;
          case 1:
<<<<<<< HEAD
            Navigator.pushNamed(context, '/home');
            break;
          case 2:
            Navigator.pushNamed(context, '/home');
            break;
          case 3:
            Navigator.pushNamed(context, '/home');
            break;
          case 4:
            Navigator.pushNamed(context, '/home');
=======
            Navigator.pushNamed(context, '/watchlist');
            break;
          case 2:
            Navigator.pushNamed(context, '/learn');
            break;
          case 3:
            Navigator.pushNamed(context, '/notifications');
            break;
          case 4:
            Navigator.pushNamed(context, '/profile');
>>>>>>> a1fe5b7592d17b8a4d105c3888380dcb912d232d
            break;
        }
      },
      items: const [
<<<<<<< HEAD
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline), label: 'Watchlist'),
        BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined), label: 'Learn'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
=======
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined),          label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline),       label: 'Watchlist'),
        BottomNavigationBarItem(icon: Icon(Icons.school_outlined),        label: 'Learn'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline),         label: 'Profile'),
>>>>>>> a1fe5b7592d17b8a4d105c3888380dcb912d232d
      ],
    );
  }
}