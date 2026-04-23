// ============================================================
// FILE: lib/screens/home_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/database_service.dart';
import '../services/yahoo_finance_service.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_card.dart';
import 'stock_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Stock> _watchlistStocks = [];
  List<Stock> _allStocks = [];
  List<Stock> _filteredStocks = [];
  Map<String, dynamic>? _dailyTip;
  bool _loading = true;
  bool _searching = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final [watchlist, all, tip] = await Future.wait([
      DatabaseService.getWatchlistStocks(),
      DatabaseService.getAllStocks(),
      DatabaseService.getDailyTip(),
    ]);
    setState(() {
      _watchlistStocks = watchlist as List<Stock>;
      _allStocks = all as List<Stock>;
      _dailyTip = tip as Map<String, dynamic>?;
      _loading = false;
    });
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() { _searching = false; _filteredStocks = []; });
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _searching = true;
      _filteredStocks = _allStocks
          .where((s) => s.ticker.toLowerCase().contains(q) || s.name.toLowerCase().contains(q))
          .toList();
    });
  }

  Future<void> _searchAndFetchTicker(String ticker) async {
    final upper = ticker.toUpperCase().trim();
    setState(() => _searching = true);
    // Check local first
    final local = _allStocks.where((s) => s.ticker == upper).toList();
    if (local.isNotEmpty) {
      setState(() => _filteredStocks = local);
      return;
    }
    // Fetch from Yahoo Finance
    final stock = await YahooFinanceService.fetchQuote(upper);
    if (stock != null) {
      await DatabaseService.upsertStock(stock);
      setState(() => _filteredStocks = [stock]);
    } else {
      setState(() => _filteredStocks = []);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticker not found. Check the symbol and try again.'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('StockStart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
            onPressed: _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: _load,
        child: _loading
            ? _buildLoading()
            : CustomScrollView(
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  onSubmitted: _searchAndFetchTicker,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search ticker or company (e.g. AAPL)',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                    suffixIcon: _searching
                        ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() { _searching = false; _filteredStocks = []; });
                      },
                    )
                        : null,
                  ),
                ),
              ),
            ),

            // Search results
            if (_searching) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    _filteredStocks.isEmpty ? 'No results' : '${_filteredStocks.length} result(s)',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (_, i) => StockCard(
                    stock: _filteredStocks[i],
                    onTap: () => _openDetail(_filteredStocks[i]),
                  ),
                  childCount: _filteredStocks.length,
                ),
              ),
            ] else ...[
              // Daily Tip
              if (_dailyTip != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: DailyTipCard(
                      title: _dailyTip!['title'],
                      body: _dailyTip!['body'],
                      category: _dailyTip!['category'],
                    ),
                  ),
                ),

              // Watchlist preview
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Watchlist Preview',
                  action: 'See All',
                  onAction: () {},
                ),
              ),
              if (_watchlistStocks.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('No stocks in watchlist yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => StockCard(
                      stock: _watchlistStocks[i],
                      onTap: () => _openDetail(_watchlistStocks[i]),
                    ),
                    childCount: _watchlistStocks.take(3).length,
                  ),
                ),

              // Risk categories
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Risk Categories'),
              ),
              SliverToBoxAdapter(child: _buildRiskTabs()),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Low Risk'),
              Tab(text: 'Medium Risk'),
              Tab(text: 'High Risk'),
            ],
          ),
          SizedBox(
            height: 220,
            child: TabBarView(
              children: ['Low', 'Medium', 'High'].map((risk) {
                final stocks = _allStocks.where((s) => s.riskLevel == risk).toList();
                if (stocks.isEmpty) {
                  return Center(child: Text('No $risk risk stocks', style: const TextStyle(color: AppTheme.textSecondary)));
                }
                return ListView.builder(
                  itemCount: stocks.length,
                  padding: const EdgeInsets.only(top: 4),
                  itemBuilder: (_, i) => StockCard(
                    stock: stocks[i],
                    onTap: () => _openDetail(stocks[i]),
                    showRisk: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      children: List.generate(5, (_) => const ShimmerCard()),
    );
  }

  void _openDetail(Stock stock) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StockDetailScreen(stock: stock)),
    ).then((_) => _load());
  }
}