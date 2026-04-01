// ============================================================
// FILE: lib/screens/home_screen.dart
// PURPOSE: SCREEN 2 — Home Dashboard.
//          Search bar + Daily Tip card + Watchlist preview.
// ============================================================

// Use this style instead:
import 'package:flutter/material.dart'; // <--- ADD THIS LINE
import 'package:stockstart/database/database_helper.dart';
import 'package:stockstart/models/stock.dart';
import 'package:stockstart/utils/app_theme.dart';
import 'package:stockstart/widgets/bottom_nav.dart';
import 'package:stockstart/widgets/stock_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper.instance;

  List<Stock> _watchlistPreview = [];      // Stocks shown in preview (max 3)
  List<Stock> _searchResults    = [];      // Results when user searches
  bool _isSearching              = false;  // Tracks if search bar is active
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  // Loads watchlist from database
  Future<void> _loadWatchlist() async {
    final stocks = await db.getWatchlistStocks();
    setState(() {
      _watchlistPreview = stocks.take(3).toList(); // Only show first 3
    });
  }

  // Called when user types in the search bar
  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
    final results = await db.searchStocks(query);
    setState(() {
      _isSearching = true;
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,

      // ── TOP APP BAR ────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('StockStart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),

      // ── BODY ───────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── SEARCH BAR ──────────────────────────────────────
            TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search stocks...',
                hintStyle: const TextStyle(color: AppColors.greyLight),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // ── SEARCH RESULTS (shown only when searching) ──────
            if (_isSearching) ...[
              Text(
                '${_searchResults.length} result(s) found',
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ..._searchResults.map((s) => StockCard(stock: s)),
              const SizedBox(height: 8),
            ],

            // ── DAILY TIP CARD ──────────────────────────────────
            if (!_isSearching) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📚 Daily Learning Tip',
                      style: TextStyle(fontSize: 11, color: AppColors.greenSoft),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Diversify Your Portfolio',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Spread your investments across different sectors to minimize risk.',
                      style: TextStyle(fontSize: 13, color: AppColors.greenSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── WATCHLIST PREVIEW HEADER ────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Watchlist Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/watchlist'),
                    child: const Text(
                      'See All →',
                      style: TextStyle(fontSize: 13, color: AppColors.green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── WATCHLIST STOCK CARDS ────────────────────────
              if (_watchlistPreview.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No stocks in watchlist yet.',
                      style: TextStyle(color: AppColors.greyLight),
                    ),
                  ),
                )
              else
                ..._watchlistPreview.map(
                      (stock) => StockCard(
                    stock: stock,
                    onTap: () {
                      // TODO: Navigate to stock detail screen
                    },
                  ),
                ),
            ],
          ],
        ),
      ),

      // ── BOTTOM NAV ─────────────────────────────────────────────
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
