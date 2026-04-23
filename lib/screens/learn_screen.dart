// ============================================================
// FILE: lib/screens/learn_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});
  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  List<Map<String, dynamic>> _tips = [];
  Set<int> _readTips = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tips = await DatabaseService.getAllTips();
    setState(() => _tips = tips);
  }

  double get _progress => _tips.isEmpty ? 0 : _readTips.length / _tips.length;

  @override
  Widget build(BuildContext context) {
    final categories = _tips.map((t) => t['category'] as String).toSet().toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Learn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withOpacity(0.2), AppTheme.surface],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Learning Progress', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                        const Spacer(),
                        Text('${(_progress * 100).toInt()}%', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: AppTheme.border,
                        color: AppTheme.primary,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${_readTips.length} of ${_tips.length} tips read', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ),

            // Tips by category
            ...categories.map((cat) {
              final catTips = _tips.where((t) => t['category'] == cat).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Text(cat, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  ),
                  ...catTips.map((tip) => _TipCard(
                    tip: tip,
                    isRead: _readTips.contains(tip['id']),
                    onRead: () => setState(() => _readTips.add(tip['id'])),
                  )),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatefulWidget {
  final Map<String, dynamic> tip;
  final bool isRead;
  final VoidCallback onRead;
  const _TipCard({required this.tip, required this.isRead, required this.onRead});

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);
        if (!widget.isRead) widget.onRead();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isRead ? AppTheme.primary.withOpacity(0.3) : AppTheme.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.isRead)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 16)
                else
                  const Icon(Icons.circle_outlined, color: AppTheme.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.tip['title'],
                    style: TextStyle(
                      color: widget.isRead ? AppTheme.primary : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppTheme.textSecondary, size: 20),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              Text(widget.tip['body'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}