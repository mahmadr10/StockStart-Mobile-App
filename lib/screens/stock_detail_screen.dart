// lib/screens/stock_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/prediction_result.dart';
import '../services/yahoo_finance_service.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'demo_trading_screen.dart';

class StockDetailScreen extends StatefulWidget {
  final Stock stock;
  const StockDetailScreen({super.key, required this.stock});
  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late Stock _stock;
  List<PricePoint> _history = [];
  PredictionResult? _prediction;
  bool _loadingChart = true;
  bool _loadingPrediction = false;
  bool _inWatchlist = false;
  String _range = '1y';

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    _inWatchlist = _stock.isInWatchlist;
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loadingChart = true);
    
    final freshStock = await YahooFinanceService.fetchQuote(_stock.ticker);
    if (freshStock != null && mounted) {
      _stock = freshStock.copyWith(isInWatchlist: _inWatchlist);
      await DatabaseService.upsertStock(_stock);
    }
    
    final history = await YahooFinanceService.fetchHistory(_stock.ticker, range: _range);
    if (mounted) {
      setState(() {
        _history = history;
        _loadingChart = false;
        _prediction = null;
      });
    }
  }

  Future<void> _runPrediction() async {
    if (_history.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least 50 data points for prediction.'), backgroundColor: AppTheme.warning),
      );
      return;
    }
    setState(() => _loadingPrediction = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final result = YahooFinanceService.computePrediction(_history);
    if (mounted) {
      setState(() {
        _prediction = result;
        _loadingPrediction = false;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    final newVal = !_inWatchlist;
    setState(() => _inWatchlist = newVal);
    await DatabaseService.toggleWatchlist(_stock.ticker, newVal);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newVal ? '${_stock.ticker} added to watchlist' : '${_stock.ticker} removed from watchlist'),
          backgroundColor: newVal ? AppTheme.primary : AppTheme.textSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUp = _stock.change >= 0;
    final changeColor = AppTheme.changeColor(_stock.change);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_stock.ticker),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _inWatchlist ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _inWatchlist ? AppTheme.primary : AppTheme.textSecondary,
            ),
            onPressed: _toggleWatchlist,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_stock.name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${_stock.price.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 34, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: changeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${isUp ? '+' : ''}${_stock.change.toStringAsFixed(2)}%',
                            style: TextStyle(color: changeColor, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildRangeSelector(),
              const SizedBox(height: 12),
              _loadingChart ? _buildChartPlaceholder() : _buildChart(),
              
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🤖 AI Trend Analysis', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadingPrediction ? null : _runPrediction,
                        icon: _loadingPrediction 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.auto_awesome_rounded),
                        label: Text(_loadingPrediction ? 'Analysing Data...' : 'Run Prediction (Max 2.5%)'),
                      ),
                    ),
                    if (_prediction != null) ...[
                      const SizedBox(height: 16),
                      _buildPredictionResult(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: const BorderSide(color: AppTheme.primary),
                    foregroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DemoTradingScreen(stock: _stock)),
                  ),
                  icon: const Icon(Icons.currency_exchange_rounded),
                  label: const Text('Open Demo Trading', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    final ranges = ['1mo', '3mo', '6mo', '1y', '2y'];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ranges.length,
        itemBuilder: (_, i) {
          final r = ranges[i];
          final active = _range == r;
          return GestureDetector(
            onTap: () { setState(() => _range = r); _loadData(); },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active ? AppTheme.primary : AppTheme.border),
              ),
              child: Text(r.toUpperCase(), style: TextStyle(color: active ? Colors.black : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    if (_history.isEmpty) {
      return Container(
        height: 200, margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
        child: const Center(child: Text('Chart data unavailable', style: TextStyle(color: AppTheme.textSecondary))),
      );
    }
    final prices = _history.map((p) => p.close).toList();
    final minP = prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.reduce((a, b) => a > b ? a : b);
    final lineColor = prices.last >= prices.first ? AppTheme.primary : AppTheme.danger;

    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _LineChartPainter(prices: prices, minP: minP, maxP: maxP, color: lineColor),
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder() => Container(
    height: 200, margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
    child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
  );

  Widget _buildPredictionResult() {
    final p = _prediction!;
    final trendColor = p.trendDirection == 'UP' ? AppTheme.primary : AppTheme.danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Forecasted Price', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              Text('\$${p.predictedPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trend Signal', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              Text(p.trendDirection, style: TextStyle(color: trendColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> prices;
  final double minP, maxP;
  final Color color;
  _LineChartPainter({required this.prices, required this.minP, required this.maxP, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;
    final range = maxP - minP == 0 ? 1 : maxP - minP;
    final path = Path();
    final h = size.height - 40;
    final w = size.width - 32;

    for (int i = 0; i < prices.length; i++) {
      final x = 16 + (i / (prices.length - 1)) * w;
      final y = size.height - 20 - ((prices[i] - minP) / range) * h;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    final linePaint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);
  }
  @override
  bool shouldRepaint(_LineChartPainter old) => old.prices != prices;
}
