// lib/screens/watchlist_screen.dart
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_card.dart';
import 'stock_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});
  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  String       _risk    = 'Low';
  List<Stock>  _stocks  = [];
  bool         _loading = true;

  @override
  void initState() { super.initState(); _load('Low'); }

  Future<void> _load(String risk) async {
    setState(() { _loading = true; _risk = risk; });
    final stocks = await DatabaseService.getWatchlistByRisk(risk);
    if (!mounted) return;
    setState(() { _stocks = stocks; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Watchlist')),
      body: Column(
        children: [
          // Risk tabs
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _tab('Low'),
                const SizedBox(width: 8),
                _tab('Medium'),
                const SizedBox(width: 8),
                _tab('High'),
              ],
            ),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primary))
                : _stocks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded,
                      size: 52,
                      color: AppTheme.textSecondary
                          .withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'No $_risk Risk stocks\nin your watchlist yet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              onRefresh: () => _load(_risk),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _stocks.length,
                itemBuilder: (_, i) => StockCard(
                  stock: _stocks[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StockDetailScreen(
                          stock: _stocks[i]),
                    ),
                  ).then((_) => _load(_risk)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String risk) {
    final active = _risk == risk;
    final color  = AppTheme.riskColor(risk);
    return Expanded(
      child: GestureDetector(
        onTap: () => _load(risk),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:  active ? color.withOpacity(0.15) : AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: color) : null,
          ),
          child: Text(
            '$risk Risk',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? color : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}