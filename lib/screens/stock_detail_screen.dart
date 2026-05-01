// lib/screens/stock_detail_screen.dart
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
  late Stock         _stock;
  List<PricePoint>   _history           = [];
  PredictionResult?  _prediction;
  bool               _loadingChart      = true;
  bool               _loadingPrediction = false;
  bool               _inWatchlist       = false;
  String             _range             = '1y';
  String             _analysisType      = 'Classification (Trend)';

  @override
  void initState() {
    super.initState();
    _stock       = widget.stock;
    _inWatchlist = widget.stock.isInWatchlist;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loadingChart = true; _prediction = null; });

    // Try fresh quote — non-blocking, fall back to stored data if offline
    try {
      final fresh = await YahooFinanceService.fetchQuote(_stock.ticker);
      if (fresh != null && mounted) {
        _stock = fresh.copyWith(isInWatchlist: _inWatchlist);
        await DatabaseService.upsertStock(_stock);
      }
    } catch (_) {}

    // Fetch price history — non-blocking
    try {
      final history = await YahooFinanceService.fetchHistory(
          _stock.ticker, range: _range);
      if (mounted) setState(() { _history = history; });
    } catch (_) {}

    if (mounted) setState(() => _loadingChart = false);
  }

  Future<void> _runPrediction() async {
    if (_history.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Need at least 50 data points for prediction.'),
        backgroundColor: AppTheme.warning,
      ));
      return;
    }
    setState(() => _loadingPrediction = true);
    await Future.delayed(const Duration(milliseconds: 300));
    final result = YahooFinanceService.computePrediction(_history);
    if (!mounted) return;
    setState(() { _prediction = result; _loadingPrediction = false; });
  }

  Future<void> _toggleWatchlist() async {
    final newVal = !_inWatchlist;
    setState(() => _inWatchlist = newVal);
    _stock = _stock.copyWith(isInWatchlist: newVal);
    await DatabaseService.toggleWatchlist(_stock.ticker, newVal);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(newVal
          ? '${_stock.ticker} added to watchlist'
          : '${_stock.ticker} removed from watchlist'),
      backgroundColor: newVal ? AppTheme.primary : AppTheme.textSecondary,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isUp        = _stock.change >= 0;
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
              _inWatchlist
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: _inWatchlist
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
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
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header price ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_stock.name,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${_stock.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 34,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: changeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${isUp ? '+' : ''}${_stock.change.toStringAsFixed(2)}%',
                            style: TextStyle(
                                color: changeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              _buildRangeSelector(),
              const SizedBox(height: 8),
              _loadingChart ? _chartPlaceholder() : _buildChart(),
              const SizedBox(height: 20),

              // ── Metrics grid ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.1,
                  children: [
                    MetricTile(
                        label: 'Market Cap',
                        value: AppTheme.formatMarketCap(_stock.marketCap)),
                    MetricTile(
                        label: 'P/E Ratio',
                        value: _stock.peRatio != null
                            ? _stock.peRatio!.toStringAsFixed(1)
                            : 'N/A'),
                    MetricTile(
                        label: '52W High',
                        value: _stock.high52w != null
                            ? '\$${_stock.high52w!.toStringAsFixed(2)}'
                            : 'N/A'),
                    MetricTile(
                        label: '52W Low',
                        value: _stock.low52w != null
                            ? '\$${_stock.low52w!.toStringAsFixed(2)}'
                            : 'N/A'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Performance summary ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Performance Summary',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      const SizedBox(height: 8),
                      Text(_stock.status,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          RiskBadge(riskLevel: _stock.riskLevel),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: changeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: changeColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              isUp ? '▲ Uptrend' : '▼ Downtrend',
                              style: TextStyle(
                                  color: changeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── AI Prediction section ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Trend Prediction',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _analysisChip('Classification (Trend)'),
                        const SizedBox(width: 8),
                        _analysisChip('Regression (Price)'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadingPrediction ? null : _runPrediction,
                        icon: _loadingPrediction
                            ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black))
                            : const Icon(Icons.auto_awesome_rounded,
                            size: 18),
                        label: Text(_loadingPrediction
                            ? 'Analysing...'
                            : 'Run AI Analysis'),
                      ),
                    ),
                    if (_history.isEmpty && !_loadingChart)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Chart data unavailable (offline). Prediction requires live data.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ),
                    if (_prediction != null) ...[
                      const SizedBox(height: 14),
                      _buildPredictionResult(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Demo Trading button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: const BorderSide(color: AppTheme.primary),
                    foregroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DemoTradingScreen(stock: _stock)),
                  ),
                  icon: const Icon(Icons.show_chart_rounded),
                  label: const Text('Open Demo Trading',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    const ranges = ['1mo', '3mo', '6mo', '1y', '2y'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ranges.map((r) {
          final active = _range == r;
          return GestureDetector(
            onTap: () {
              setState(() { _range = r; _prediction = null; });
              _loadData();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.primary.withOpacity(0.15)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active ? AppTheme.primary : AppTheme.border),
              ),
              child: Text(r,
                  style: TextStyle(
                      color: active
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    if (_history.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded,
                  color: AppTheme.textSecondary, size: 32),
              SizedBox(height: 8),
              Text('No chart data available\n(offline or invalid ticker)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    final prices    = _history.map((p) => p.close).toList();
    final minP      = prices.reduce((a, b) => a < b ? a : b);
    final maxP      = prices.reduce((a, b) => a > b ? a : b);
    final lineColor = prices.last >= prices.first
        ? AppTheme.primary
        : AppTheme.danger;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 200,
          child: CustomPaint(
            painter: _ChartPainter(
                prices: prices, minP: minP, maxP: maxP, color: lineColor),
            child: Container(),
          ),
        ),
      ),
    );
  }

  Widget _chartPlaceholder() => Container(
    height: 200,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primary)),
  );

  Widget _analysisChip(String type) {
    final active = _analysisType == type;
    return GestureDetector(
      onTap: () =>
          setState(() { _analysisType = type; _prediction = null; }),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.accent.withOpacity(0.2)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border:
          Border.all(color: active ? AppTheme.accent : AppTheme.border),
        ),
        child: Text(type,
            style: TextStyle(
                color:
                active ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildPredictionResult() {
    final p       = _prediction!;
    final isClass = _analysisType.contains('Classification');
    final trendColor =
    p.trendDirection == 'UP' ? AppTheme.primary : AppTheme.danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isClass ? 'Trend Prediction' : 'Price Forecast',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(p.signalStrength,
                    style: const TextStyle(
                        color: AppTheme.info,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Divider(color: AppTheme.border, height: 20),

          if (isClass) ...[
            Row(
              children: [
                Text(
                  p.trendDirection == 'UP' ? '▲  BULLISH' : '▼  BEARISH',
                  style: TextStyle(
                      color: trendColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(
                  '${(p.trendConfidence * 100).toStringAsFixed(1)}% confidence',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: p.trendConfidence,
                backgroundColor: AppTheme.border,
                color: trendColor,
                minHeight: 6,
              ),
            ),
          ] else ...[
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Predicted Next Price',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                    Text('\$${p.predictedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('RMSE Estimate',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                    Text('±${p.rmseEstimate.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppTheme.warning,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          const Text('Technical Indicators',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3)),
          const SizedBox(height: 8),
          _indRow('RSI (14)', p.rsi.toStringAsFixed(1), _rsiColor(p.rsi)),
          _indRow('MACD Diff', p.macdDiff.toStringAsFixed(3),
              p.macdDiff >= 0 ? AppTheme.primary : AppTheme.danger),
          _indRow('Dist. from SMA50', p.distFromSma.toStringAsFixed(2),
              p.distFromSma >= 0 ? AppTheme.primary : AppTheme.danger),
          _indRow('BB Width', p.bbWidth.toStringAsFixed(4), AppTheme.info),
        ],
      ),
    );
  }

  Widget _indRow(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Color _rsiColor(double rsi) {
    if (rsi > 70) return AppTheme.danger;
    if (rsi < 30) return AppTheme.warning;
    return AppTheme.primary;
  }
}

// ─── Chart Painter ────────────────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final List<double> prices;
  final double minP, maxP;
  final Color color;

  const _ChartPainter(
      {required this.prices,
        required this.minP,
        required this.maxP,
        required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;
    final range = (maxP - minP) == 0 ? 1.0 : maxP - minP;
    const p = EdgeInsets.fromLTRB(16, 12, 16, 12);
    final w = size.width  - p.left - p.right;
    final h = size.height - p.top  - p.bottom;

    final path = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = p.left + (i / (prices.length - 1)) * w;
      final y = p.top  + h - ((prices[i] - minP) / range) * h;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    // Fill
    final fill = Path.from(path)
      ..lineTo(p.left + w, p.top + h)
      ..lineTo(p.left, p.top + h)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.prices != prices || old.color != color;
}