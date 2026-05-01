// lib/screens/home_screen.dart
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
  List<Stock>           _watchlist    = [];
  List<Stock>           _allStocks    = [];
  List<Stock>           _filtered     = [];
  Map<String, dynamic>? _tip;
  bool                  _loading      = true;
  bool                  _searching    = false;
  bool                  _fetchingLive = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _searching = false; });
    _searchCtrl.clear();
    try {
      final results = await Future.wait([
        DatabaseService.getWatchlistStocks(),
        DatabaseService.getAllStocks(),
        DatabaseService.getDailyTip(),
      ]);
      
      if (!mounted) return;
      
      var watchlist = results[0] as List<Stock>;
      setState(() {
        _watchlist = watchlist;
        _allStocks = results[1] as List<Stock>;
        _tip       = results[2] as Map<String, dynamic>?;
        _loading   = false;
      });

      // Background refresh for watchlist prices
      if (watchlist.isNotEmpty) {
        final tickers = watchlist.map((s) => s.ticker).toList();
        final fresh   = await YahooFinanceService.fetchQuotes(tickers);
        if (fresh.isNotEmpty && mounted) {
          for (var s in fresh) {
            await DatabaseService.upsertStock(s.copyWith(isInWatchlist: true));
          }
          final updatedWatchlist = await DatabaseService.getWatchlistStocks();
          setState(() => _watchlist = updatedWatchlist);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onSearch(String q) {
    if (q.isEmpty) {
      setState(() { _searching = false; _filtered = []; });
      return;
    }
    final ql = q.toLowerCase();
    setState(() {
      _searching = true;
      _filtered  = _allStocks.where((s) =>
      s.ticker.toLowerCase().contains(ql) ||
          s.name.toLowerCase().contains(ql)).toList();
    });
  }

  Future<void> _fetchTicker(String raw) async {
    final ticker = raw.toUpperCase().trim();
    if (ticker.isEmpty) return;

    setState(() { _fetchingLive = true; _searching = true; });
    
    try {
      final stock = await YahooFinanceService.fetchQuote(ticker);
      if (!mounted) return;
      
      if (stock != null) {
        // Keep the watchlist status if it exists locally
        final existing = _allStocks.where((s) => s.ticker == ticker).toList();
        final isWatched = existing.isNotEmpty ? existing.first.isInWatchlist : false;
        
        final updatedStock = stock.copyWith(isInWatchlist: isWatched);
        await DatabaseService.upsertStock(updatedStock);
        
        setState(() { 
          _filtered = [updatedStock]; 
          // Update allStocks so the change is reflected immediately
          int idx = _allStocks.indexWhere((s) => s.ticker == ticker);
          if(idx != -1) _allStocks[idx] = updatedStock; else _allStocks.add(updatedStock);
        });
      } else {
        // Fallback to local if live fetch fails
        final local = _allStocks.where((s) => s.ticker == ticker).toList();
        if (local.isNotEmpty) {
          setState(() { _filtered = local; });
        } else {
          setState(() { _filtered = []; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ticker "$ticker" not found online.'),
            backgroundColor: AppTheme.danger,
          ));
        }
      }
    } catch (_) {
      if (mounted) setState(() { _filtered = []; });
    }
    if (mounted) setState(() => _fetchingLive = false);
  }

  void _openDetail(Stock s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StockDetailScreen(stock: s)),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('StockStart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppTheme.textSecondary),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: _load,
        child: _loading
            ? ListView(
            children: List.generate(5, (_) => const ShimmerCard()))
            : CustomScrollView(
          slivers: [
            // ── Search bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  onSubmitted: _fetchTicker,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search ticker (e.g. AAPL) and press Enter',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textSecondary),
                    suffixIcon: _searching
                        ? (_fetchingLive
                        ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        ))
                        : IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searching = false;
                            _filtered  = [];
                          });
                        }))
                        : null,
                  ),
                ),
              ),
            ),

            // ── SEARCH RESULTS ──
            if (_searching) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text(
                    _filtered.isEmpty && !_fetchingLive
                        ? 'No results found'
                        : (_fetchingLive ? 'Fetching live data...' : '${_filtered.length} result(s)'),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (_, i) => StockCard(
                    stock: _filtered[i],
                    onTap: () => _openDetail(_filtered[i]),
                  ),
                  childCount: _filtered.length,
                ),
              ),
            ] else ...[
              // ── DAILY TIP ──
              if (_tip != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: DailyTipCard(
                      title:    _tip!['title'] as String,
                      body:     _tip!['body']  as String,
                      category: _tip!['category'] as String,
                    ),
                  ),
                ),

              // ── WATCHLIST PREVIEW ──
              SliverToBoxAdapter(
                child: SectionHeader(
                  title:    'Watchlist Preview',
                  action:   'Refresh',
                  onAction: _load,
                ),
              ),
              if (_watchlist.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text('No stocks in watchlist yet.',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13)),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => StockCard(
                      stock: _watchlist[i],
                      onTap: () => _openDetail(_watchlist[i]),
                    ),
                    childCount:
                    _watchlist.length > 5 ? 5 : _watchlist.length,
                  ),
                ),

              // ── RISK CATEGORIES ──
              const SliverToBoxAdapter(
                  child: SectionHeader(title: 'Risk Categories')),
              SliverToBoxAdapter(child: _buildRiskTabs()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Low Risk'),
              Tab(text: 'Medium Risk'),
              Tab(text: 'High Risk'),
            ],
          ),
          SizedBox(
            height: 280,
            child: TabBarView(
              children: ['Low', 'Medium', 'High'].map((risk) {
                final stocks =
                _allStocks.where((s) => s.riskLevel == risk).toList();
                if (stocks.isEmpty) {
                  return Center(
                      child: Text('No $risk risk stocks',
                          style: const TextStyle(
                              color: AppTheme.textSecondary)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: stocks.length,
                  itemBuilder: (_, i) => StockCard(
                    stock: stocks[i],
                    showRisk: false,
                    onTap: () => _openDetail(stocks[i]),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
