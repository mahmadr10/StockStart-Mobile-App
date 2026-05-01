// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {'icon': '🟢', 'title': 'Market Open',       'subtitle': 'NASDAQ is now live',                    'time': '10:00 AM', 'read': false},
    {'icon': '📈', 'title': 'Price Alert: AAPL',  'subtitle': 'Apple Inc. is up 2.3% today',           'time': '9:45 AM',  'read': false},
    {'icon': '💡', 'title': 'New Learning Tip',   'subtitle': 'RSI Indicator — tap to read',           'time': '9:00 AM',  'read': true},
    {'icon': '⚠️', 'title': 'Price Alert: TSLA',  'subtitle': 'Tesla fell below \$170 threshold',      'time': 'Yesterday','read': true},
    {'icon': '📉', 'title': 'Market Close',        'subtitle': 'NASDAQ closed down 0.4%',              'time': 'Yesterday','read': true},
    {'icon': '💡', 'title': 'New Learning Tip',   'subtitle': 'Bollinger Bands explained',             'time': '2 days ago','read': true},
  ];

  int get _unreadCount => _notifications.where((n) => !(n['read'] as bool)).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n['read'] = true;
      }
    });
  }

  void _markRead(int index) {
    if (!(_notifications[index]['read'] as bool)) {
      setState(() => _notifications[index]['read'] = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Alerts'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _unreadCount > 0 ? _markAllRead : null,
            child: Text(
              'Mark all read',
              style: TextStyle(
                color: _unreadCount > 0
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
          child: Text('No notifications',
              style: TextStyle(color: AppTheme.textSecondary)))
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(
            color: AppTheme.border,
            height: 1,
            indent: 16,
            endIndent: 16),
        itemBuilder: (_, i) {
          final n      = _notifications[i];
          final unread = !(n['read'] as bool);
          return GestureDetector(
            onTap: () => _markRead(i),
            child: Container(
              color: unread
                  ? AppTheme.primary.withOpacity(0.04)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(n['icon'] as String,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n['title'] as String,
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: unread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 14),
                              ),
                            ),
                            if (unread)
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(n['subtitle'] as String,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(n['time'] as String,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}