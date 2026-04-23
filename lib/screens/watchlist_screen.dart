// ============================================================
// FILE: lib/screens/watchlist_screen.dart
// PURPOSE: SCREEN 3 — Watchlist with Low / Medium / High Risk tabs.
// ============================================================

import 'package:flutter/material.dart';
import 'package:stockstart/database/database_helper.dart';
import 'package:stockstart/models/stock.dart';
import 'package:stockstart/utils/app_theme.dart';
import 'package:stockstart/widgets/bottom_nav.dart';
import 'package:stockstart/widgets/stock_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final db = DatabaseHelper.instance;

  String _selectedRisk = 'Low';
  List<Stock> _stocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStocks('Low');
  }

  Future<void> _loadStocks(String risk) async {
    setState(() => _isLoading = true);

    final stocks = await db.getWatchlistByRisk(risk);

    setState(() {
      _stocks = stocks;
      _selectedRisk = risk;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text('My Watchlist'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          // ── RISK TABS ──
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildTab('Low'),
                const SizedBox(width: 8),
                _buildTab('Medium'),
                const SizedBox(width: 8),
                _buildTab('High'),
              ],
            ),
          ),

          // ── STOCK LIST ──
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
                : _stocks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No $_selectedRisk Risk stocks\nin your watchlist',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _stocks.length,
              itemBuilder: (context, index) {
                return StockCard(
                  stock: _stocks[index],
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildTab(String risk) {
    final isActive = _selectedRisk == risk;

    final Color color = switch (risk) {
      'Low' => AppTheme.primary,
      'Medium' => AppTheme.warning,
      _ => AppTheme.danger,
    };

    return Expanded(
      child: GestureDetector(
        onTap: () => _loadStocks(risk),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? color.withOpacity(0.15)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(color: color) : null,
          ),
          child: Text(
            '$risk Risk',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? color : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}