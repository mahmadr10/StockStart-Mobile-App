// ============================================================
// FILE: lib/screens/stock_detail_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/prediction_result.dart';
import '../services/yahoo_finance_service.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_card.dart';
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
  String _analysisType = 'Classification (Trend)';

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    _inWatchlist = _stock.isInWatchlist;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loadingChart = true);
    // Fetch fresh quote
    final freshStock = await YahooFinanceService.fetchQuote(_stock.ticker);
    if (freshStock != null) {
      _stock = freshStock.copyWith(isInWatchlist: _inWatchlist);
      await DatabaseService.upsertStock(_stock);
    }
    // Fetch history
    final history = await YahooFinanceService.fetchHistory(_stock.ticker, range: _range);
    setState(() {
      _history = history;
      _loadingChart = false;
    });
  }

  Future<void> _runPrediction() async {
    if (_history.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least 50 data points for prediction.'), backgroundColor: AppTheme.warning),
      );
      return;
    }
    setState(() => _loadingPrediction = true);
    final result = YahooFinanceService.computePrediction(_history);
    setState(() {
      _prediction = result;
      _loadingPrediction = false;
    });
  }

  Future<void> _toggleWatchlist() async {
    setState(() => _inWatchlist = !_inWatchlist);
    await DatabaseService.toggleWatchlist(_stock.ticker, _inWatchlist);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_inWatchlist ? '${_stock.ticker} added to watchlist' : '${_stock.ticker} removed from watchlist'),
        backgroundColor: _inWatchlist ? AppTheme.primary : AppTheme.textSecondary,
      ),
    );
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
        backgroundColor: AppTheme.surface,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_stock.name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${_stock.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 32, fontWeight: FontWeight.w800),
                        ),
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

              const SizedBox(height: 12),

              // Range selector
              _buildRangeSelector(),

              const SizedBox(height: 8),

              // Chart
              _loadingChart ? _buildChartPlaceholder() : _buildChart(),

              const SizedBox(height: 20),

              // Metrics row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: [
                    MetricTile(label: 'Market Cap', value: AppTheme.formatMarketCap(_stock.marketCap)),
                    MetricTile(label: 'P/E Ratio', value: _stock.peRatio != null ? _stock.peRatio!.toStringAsFixed(1) : 'N/A'),
                    MetricTile(label: '52W High', value: _stock.high52w != null ? '\$${_stock.high52w!.toStringAsFixed(2)}' : 'N/A'),
                    MetricTile(label: '52W Low', value: _stock.low52w != null ? '\$${_stock.low52w!.toStringAsFixed(2)}' : 'N/A'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Performance summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Performance Summary', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 8),
                      Text(_stock.status, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          RiskBadge(riskLevel: _stock.riskLevel),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: changeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: changeColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              isUp ? '▲ Uptrend' : '▼ Downtrend',
                              style: TextStyle(color: changeColor, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── AI Prediction Section ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🤖 AI Market Analysis', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Powered by RSI · MACD · SMA · Bollinger Bands', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 12),

                    // Analysis type picker
                    Row(
                      children: ['Classification (Trend)', 'Regression (Price)'].map((type) {
                        final selected = _analysisType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _analysisType = type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadingPrediction ? null : _runPrediction,
                        icon: _loadingPrediction
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Icon(Icons.rocket_launch_rounded, size: 18),
                        label: Text(_loadingPrediction ? 'Analysing...' : '🚀 Run Analysis'),
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

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleWatchlist,
                        icon: Icon(_inWatchlist ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded),
                        label: Text(_inWatchlist ? 'Remove Watchlist' : 'Add to Watchlist'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _inWatchlist ? AppTheme.danger : AppTheme.primary),
                          foregroundColor: _inWatchlist ? AppTheme.danger : AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DemoTradingScreen(stock: _stock)),
                          );
                        },
                        icon: const Icon(Icons.trending_up_rounded, size: 18),
                        label: const Text('Demo Trade'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    final ranges = ['1mo', '3mo', '6mo', '1y', '2y', '5y'];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ranges.length,
        itemBuilder: (_, i) {
          final r = ranges[i];
          final selected = _range == r;
          return GestureDetector(
            onTap: () {
              setState(() => _range = r);
              _loadData();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
              ),
              child: Text(
                r.toUpperCase(),
                style: TextStyle(
                  color: selected ? Colors.black : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    if (_history.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No chart data available', style: TextStyle(color: AppTheme.textSecondary))),
      );
    }

    final prices = _history.map((p) => p.close).toList();
    final minP = prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.reduce((a, b) => a > b ? a : b);
    final isUp = prices.last >= prices.first;
    final lineColor = isUp ? AppTheme.primary : AppTheme.danger;

    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: _LinechartPainter(prices: prices, minP: minP, maxP: maxP, color: lineColor),
        child: Container(),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
    );
  }

  Widget _buildPredictionResult() {
    final p = _prediction!;
    final isClassification = _analysisType.contains('Classification');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isClassification ? 'Trend Prediction' : 'Price Forecast',
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(p.signalStrength, style: const TextStyle(color: AppTheme.info, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Divider(color: AppTheme.border, height: 20),

          if (isClassification) ...[
            Row(
              children: [
                Text(
                  p.trendDirection == 'UP' ? '▲ BULLISH' : '▼ BEARISH',
                  style: TextStyle(
                    color: p.trendDirection == 'UP' ? AppTheme.primary : AppTheme.danger,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(p.trendConfidence * 100).toStringAsFixed(1)}% conf.',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Confidence bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: p.trendConfidence,
                backgroundColor: AppTheme.border,
                color: p.trendDirection == 'UP' ? AppTheme.primary : AppTheme.danger,
                minHeight: 6,
              ),
            ),
          ] else ...[
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Predicted Next Price', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text(
                      '\$${p.predictedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('RMSE Estimate', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text(
                      '±${p.rmseEstimate.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppTheme.warning, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          const Text('Technical Indicators', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildIndicatorRow('RSI (14)', p.rsi.toStringAsFixed(1), _rsiColor(p.rsi)),
          _buildIndicatorRow('MACD Diff', p.macdDiff.toStringAsFixed(3), p.macdDiff >= 0 ? AppTheme.primary : AppTheme.danger),
          _buildIndicatorRow('Dist. from SMA50', p.distFromSma.toStringAsFixed(2), p.distFromSma >= 0 ? AppTheme.primary : AppTheme.danger),
          _buildIndicatorRow('BB Width', p.bbWidth.toStringAsFixed(4), AppTheme.info),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Color _rsiColor(double rsi) {
    if (rsi > 70) return AppTheme.danger;
    if (rsi < 30) return AppTheme.warning;
    return AppTheme.primary;
  }
}

// ── Custom line chart painter ──
class _LinechartPainter extends CustomPainter {
  final List<double> prices;
  final double minP;
  final double maxP;
  final Color color;

  _LinechartPainter({required this.prices, required this.minP, required this.maxP, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final range = maxP - minP == 0 ? 1 : maxP - minP;
    final padding = const EdgeInsets.fromLTRB(16, 12, 16, 12);

    final w = size.width - padding.left - padding.right;
    final h = size.height - padding.top - padding.bottom;

    // Gradient fill
    final path = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = padding.left + (i / (prices.length - 1)) * w;
      final y = padding.top + h - ((prices[i] - minP) / range) * h;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    final fillPath = Path.from(path)
      ..lineTo(padding.left + w, padding.top + h)
      ..lineTo(padding.left, padding.top + h)
      ..close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_LinechartPainter old) => old.prices != prices;
}