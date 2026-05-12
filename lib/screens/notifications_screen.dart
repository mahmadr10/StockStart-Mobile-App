// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_Alert> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final trades = await DatabaseService.getAllTrades();
      final tradeAlerts = trades.map((t) => _Alert.fromTrade(t)).toList();

      final staticAlerts = [
        _Alert(
          icon: '🟢',
          title: 'Market Open',
          subtitle: 'NASDAQ is now live',
          time: '10:00 AM',
          read: true,
          ticker: null,
        ),
        _Alert(
          icon: '💡',
          title: 'New Learning Tip',
          subtitle: 'Bollinger Bands explained',
          time: '2 days ago',
          read: true,
          ticker: null,
        ),
      ];

      if (!mounted) return;
      setState(() {
        _alerts = [...tradeAlerts, ...staticAlerts];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _unreadCount => _alerts.where((a) => !a.read).length;

  void _markAllRead() {
    setState(() {
      for (final a in _alerts) {
        a.read = true;
      }
    });
  }

  void _markRead(int index) {
    if (!_alerts[index].read) {
      setState(() => _alerts[index].read = true);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppTheme.textSecondary),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: AppTheme.primary))
          : _alerts.isEmpty
          ? const Center(
          child: Text('No alerts yet',
              style: TextStyle(color: AppTheme.textSecondary)))
          : RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _alerts.length,
          separatorBuilder: (_, __) => const Divider(
              color: AppTheme.border,
              height: 1,
              indent: 16,
              endIndent: 16),
          itemBuilder: (_, i) {
            final a = _alerts[i];
            return GestureDetector(
              onTap: () => _markRead(i),
              child: Container(
                color: !a.read
                    ? AppTheme.primary.withOpacity(0.04)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Icon / avatar
                    a.ticker != null
                        ? Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.info.withOpacity(0.12),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppTheme.info,
                          size: 22),
                    )
                        : Text(a.icon,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  a.title,
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: !a.read
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ),
                              if (!a.read)
                                Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(a.subtitle,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12)),
                          if (a.ticker != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                AppTheme.info.withOpacity(0.12),
                                borderRadius:
                                BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.ticker!,
                                style: const TextStyle(
                                    color: AppTheme.info,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(a.time,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Alert {
  final String icon;
  final String title;
  final String subtitle;
  final String time;
  bool read;
  final String? ticker;

  _Alert({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.read,
    this.ticker,
  });

  factory _Alert.fromTrade(Trade t) {
    final isBuy = t.type == 'BUY';
    final timeAgo = _calcTimeAgo(t.timestamp);
    return _Alert(
      icon: isBuy ? '📈' : '📉',
      title: '${isBuy ? 'Bought' : 'Sold'} ${t.quantity} x ${t.ticker}',
      subtitle:
      '${isBuy ? 'Purchased' : 'Sold'} ${t.quantity} share(s) of ${t.ticker} '
          'at \$${t.priceAtTrade.toStringAsFixed(2)} — total \$${t.totalValue.toStringAsFixed(2)}.',
      time: timeAgo,
      read: false,
      ticker: t.ticker,
    );
  }

  static String _calcTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}