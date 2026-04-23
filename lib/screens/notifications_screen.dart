// ============================================================
// FILE: lib/screens/notifications_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<Map<String, dynamic>> _notifications = [
    {'icon': '🟢', 'title': 'Market Open', 'subtitle': 'NASDAQ is now live', 'time': '10:00 AM', 'read': false},
    {'icon': '📈', 'title': 'Price Alert: AAPL', 'subtitle': 'Apple Inc. is up 2.3% today', 'time': '9:45 AM', 'read': false},
    {'icon': '💡', 'title': 'New Learning Tip', 'subtitle': 'RSI Indicator — tap to read', 'time': '9:00 AM', 'read': true},
    {'icon': '⚠️', 'title': 'Price Alert: TSLA', 'subtitle': 'Tesla fell below \$170 threshold', 'time': 'Yesterday', 'read': true},
    {'icon': '📉', 'title': 'Market Close', 'subtitle': 'NASDAQ closed down 0.4%', 'time': 'Yesterday', 'read': true},
    {'icon': '💡', 'title': 'New Learning Tip', 'subtitle': 'Bollinger Bands explained', 'time': '2 days ago', 'read': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(color: AppTheme.border, height: 1, indent: 16, endIndent: 16),
        itemBuilder: (_, i) {
          final n = _notifications[i];
          final unread = !(n['read'] as bool);
          return Container(
            color: unread ? AppTheme.primary.withOpacity(0.04) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(n['icon'] as String, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(n['title'] as String, style: TextStyle(color: AppTheme.textPrimary, fontWeight: unread ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
                          if (unread) ...[
                            const SizedBox(width: 6),
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(n['subtitle'] as String, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Text(n['time'] as String, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}