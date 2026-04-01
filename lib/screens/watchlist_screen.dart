// ============================================================
// FILE: lib/screens/watchlist_screen.dart
// PURPOSE: SCREEN 3 — Watchlist with Low / Medium / High Risk tabs.
//          Loads filtered stocks from the database.
// ============================================================

import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/stock.dart';
import '../../utils/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/stock_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final db = DatabaseHelper.instance;

  String _selectedRisk = 'Low'; // Currently selected tab
  List<Stock> _stocks  = [];
  bool _isLoading      = true;

  @override
  void initState() {
    super.initState();
    _loadStocks('Low'); // Load Low Risk tab by default
  }

  // Loads stocks from DB filtered by risk level
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
      backgroundColor: AppColors.pageBg,

      // ── APP BAR ────────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('My Watchlist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ── BODY ───────────────────────────────────────────────────
      body: Column(
        children: [

          // ── RISK TABS ─────────────────────────────────────────
          Container(
            color: AppColors.white,
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

          // ── STOCK LIST ────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                : _stocks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48, color: AppColors.greyLight),
                  const SizedBox(height: 12),
                  Text(
                    'No $_selectedRisk Risk stocks\nin your watchlist',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.greyLight, fontSize: 14),
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
                  onTap: () {
                    // TODO: Navigate to stock detail screen
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ── BOTTOM NAV ─────────────────────────────────────────────
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  // Builds a single risk tab button
  Widget _buildTab(String risk) {
    final isActive = _selectedRisk == risk;
    final color = switch (risk) {
      'Low'    => AppColors.green,
      'Medium' => AppColors.amber,
      _        => AppColors.red,
    };

    return Expanded(
      child: GestureDetector(
        onTap: () => _loadStocks(risk),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.12) : AppColors.greyBg,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(color: color, width: 1.5)
                : null,
          ),
          child: Text(
            '$risk Risk',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? color : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}