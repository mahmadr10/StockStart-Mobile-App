// lib/services/yahoo_finance_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/prediction_result.dart';

class YahooFinanceService {
  static const _quoteBase = 'https://query2.finance.yahoo.com/v7/finance/quote';
  static const _chartBase = 'https://query2.finance.yahoo.com/v8/finance/chart';

  static const _hdrs = {
    'User-Agent':
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Connection': 'keep-alive',
  };

  // ─────────────────────────────────────────────
  //  Single Quote
  // ─────────────────────────────────────────────
  static Future<Stock?> fetchQuote(String ticker) async {
    if (kIsWeb) return _getWebMockQuote(ticker);

    ticker = ticker.toUpperCase().trim();
    try {
      final uri = Uri.parse(
        '$_quoteBase?symbols=$ticker'
            '&fields=shortName,longName,regularMarketPrice,'
            'regularMarketChangePercent,marketCap,trailingPE,'
            'regularMarketVolume,fiftyTwoWeekHigh,fiftyTwoWeekLow',
      );
      final res = await http
          .get(uri, headers: _hdrs)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final result = data['quoteResponse']?['result'] as List?;
        if (result != null && result.isNotEmpty) {
          return _parseQuote(result[0], ticker);
        }
      }
      return await _fetchFromChart(ticker);
    } catch (_) {
      return await _fetchFromChart(ticker);
    }
  }

  static Future<Stock?> _fetchFromChart(String ticker) async {
    try {
      final uri = Uri.parse('$_chartBase/$ticker?interval=1d&range=1d');
      final res = await http
          .get(uri, headers: _hdrs)
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final result = data['chart']?['result'] as List?;
      if (result == null || result.isEmpty) return null;

      final meta = result[0]['meta'];
      final price = _d(meta['regularMarketPrice']);
      final prevClose = _d(meta['chartPreviousClose'] ?? price);
      final change =
      prevClose != 0 ? ((price - prevClose) / prevClose) * 100 : 0.0;

      return Stock(
        name: ticker,
        ticker: ticker,
        price: price,
        change: change,
        riskLevel: _risk(change),
        status: _status(change),
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  //  Batch Quotes  (used by HomeScreen watchlist refresh)
  // ─────────────────────────────────────────────
  /// Fetches multiple tickers in one API call using the comma-separated
  /// symbols parameter. Falls back to individual fetches if batch fails.
  static Future<List<Stock>> fetchQuotes(List<String> tickers) async {
    if (tickers.isEmpty) return [];
    if (kIsWeb) {
      return Future.wait(tickers.map(_getWebMockQuote));
    }

    final symbols = tickers.map((t) => t.toUpperCase().trim()).join(',');
    try {
      final uri = Uri.parse(
        '$_quoteBase?symbols=$symbols'
            '&fields=shortName,longName,regularMarketPrice,'
            'regularMarketChangePercent,marketCap,trailingPE,'
            'regularMarketVolume,fiftyTwoWeekHigh,fiftyTwoWeekLow',
      );
      final res = await http
          .get(uri, headers: _hdrs)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final result = data['quoteResponse']?['result'] as List?;
        if (result != null && result.isNotEmpty) {
          return result
              .map((q) => _parseQuote(q, q['symbol']?.toString() ?? ''))
              .where((s) => s.ticker.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {}

    // Fallback: fetch individually and collect non-null results
    final results = await Future.wait(
      tickers.map((t) => fetchQuote(t)),
    );
    return results.whereType<Stock>().toList();
  }

  // ─────────────────────────────────────────────
  //  History
  // ─────────────────────────────────────────────
  static Future<List<PricePoint>> fetchHistory(
      String ticker, {
        String range = '1y',
      }) async {
    if (kIsWeb) return _getWebMockHistory();

    try {
      final uri =
      Uri.parse('$_chartBase/$ticker?interval=1d&range=$range');
      final res = await http
          .get(uri, headers: _hdrs)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      final chart = data['chart']?['result'] as List?;
      if (chart == null || chart.isEmpty) return [];

      final r0 = chart[0];
      final ts = List<int>.from(r0['timestamp'] ?? []);
      final q0 = r0['indicators']?['quote']?[0] ?? {};
      final closes = _dl(q0['close']);

      final out = <PricePoint>[];
      for (int i = 0; i < ts.length && i < closes.length; i++) {
        if (closes[i] > 0) {
          out.add(PricePoint(
            date: DateTime.fromMillisecondsSinceEpoch(ts[i] * 1000),
            close: closes[i],
          ));
        }
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────
  //  Core Prediction  (OLS + Aligned Classifier)
  // ─────────────────────────────────────────────
  /// Uses the last [regressionWindow] days (default 14) to fit y = mx + b
  /// via Ordinary Least Squares, then projects one step ahead.
  ///
  /// The classifier (RSI, MACD, SMA distance) is then **forced to agree**
  /// with the regression sign so both outputs are always consistent.
  ///
  /// The final predicted price is hard-capped at ±2.5 % of current close.
  static PredictionResult computePrediction(
      List<PricePoint> history, {
        int regressionWindow = 14,
      }) {
    // ── Guard: need at least (regressionWindow + 36) points ──────────────
    if (history.length < regressionWindow + 36) {
      return PredictionResult(
        trendDirection: 'N/A',
        trendConfidence: 0,
        predictedPrice: history.isNotEmpty ? history.last.close : 0,
        rmseEstimate: 0,
        rsi: 50,
        macdDiff: 0,
        distFromSma: 0,
        bbWidth: 0,
        signalStrength: 'Insufficient Data',
      );
    }

    final cl = history.map((p) => p.close).toList();
    final currentPrice = cl.last;

    // ── 1. OLS Linear Regression over last [regressionWindow] closes ──────
    //
    //   x  = 0, 1, 2, …, n-1   (time index)
    //   y  = closing prices
    //
    //   slope m = (n·Σxy − Σx·Σy) / (n·Σx² − (Σx)²)
    //   intercept b = (Σy − m·Σx) / n
    //   predicted price = m·n + b   (one step beyond the window)
    //
    final window = cl.sublist(cl.length - regressionWindow);
    final n = window.length;

    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      sumX  += i;
      sumY  += window[i];
      sumXY += i * window[i];
      sumX2 += i * i.toDouble();
    }

    final denom = n * sumX2 - sumX * sumX;
    final slope = denom != 0 ? (n * sumXY - sumX * sumY) / denom : 0.0;
    final intercept = (sumY - slope * sumX) / n;

    // Raw OLS prediction (one step ahead, index = n)
    final rawOlsPred = slope * n + intercept;

    // ── 2. RMSE of the OLS fit inside the window ──────────────────────────
    double ssRes = 0;
    for (int i = 0; i < n; i++) {
      final fitted = slope * i + intercept;
      final residual = window[i] - fitted;
      ssRes += residual * residual;
    }
    final rmse = sqrt(ssRes / n);

    // ── 3. Technical indicators (used for confidence, NOT direction) ───────
    final rsi = _computeRSI(cl, 14);
    final sma50 = cl.sublist(cl.length - 50).reduce((a, b) => a + b) / 50;
    final distFromSma = currentPrice - sma50;
    final macdDiff = _computeEMA(cl, 12) - _computeEMA(cl, 26);
    final bbWidth = _computeBBWidth(cl, 20);

    // ── 4. Direction is 100 % determined by OLS slope sign ────────────────
    //   Positive slope  → UP   (regression predicts higher price)
    //   Negative slope  → DOWN (regression predicts lower price)
    final bool isUp = slope >= 0;

    // ── 5. Confidence: how consistently do indicators AGREE with OLS? ─────
    //   Each indicator that agrees with slope adds weight.
    //   Score is normalised to [0, 1].
    double agreementScore = 0.0;

    // RSI agreement: RSI > 50 agrees with UP, RSI < 50 agrees with DOWN
    if (isUp && rsi > 50)  agreementScore += 0.30;
    if (!isUp && rsi < 50) agreementScore += 0.30;

    // MACD agreement
    if (isUp && macdDiff > 0)  agreementScore += 0.35;
    if (!isUp && macdDiff < 0) agreementScore += 0.35;

    // SMA distance agreement
    if (isUp && distFromSma > 0)  agreementScore += 0.25;
    if (!isUp && distFromSma < 0) agreementScore += 0.25;

    // Base confidence starts at 0.50 (OLS alone), boosted by agreement
    final confidence = 0.50 + agreementScore * 0.50; // range [0.50, 1.00]

    // ── 6. Apply ±2.5 % hard cap to predicted price ───────────────────────
    //   The OLS prediction drives the sign; the magnitude is capped.
    final maxChange = currentPrice * 0.025;
    double predictedPrice;

    if (isUp) {
      // Must be strictly ABOVE current price
      final rawChange = rawOlsPred - currentPrice;
      final clampedChange = rawChange.clamp(0.0001, maxChange);
      predictedPrice = currentPrice + clampedChange;
    } else {
      // Must be strictly BELOW current price
      final rawChange = currentPrice - rawOlsPred;
      final clampedChange = rawChange.clamp(0.0001, maxChange);
      predictedPrice = currentPrice - clampedChange;
    }

    // ── 7. Build result ───────────────────────────────────────────────────
    return PredictionResult(
      trendDirection: isUp ? 'UP' : 'DOWN',
      trendConfidence: confidence,
      predictedPrice: predictedPrice,
      rmseEstimate: rmse,
      rsi: rsi,
      macdDiff: macdDiff,
      distFromSma: distFromSma,
      bbWidth: bbWidth,
      signalStrength: confidence >= 0.80
          ? 'Strong'
          : confidence >= 0.65
          ? 'Moderate'
          : 'Weak',
    );
  }

  // ─────────────────────────────────────────────
  //  Technical Indicator Helpers
  // ─────────────────────────────────────────────

  /// Relative Strength Index (Wilder smoothing)
  static double _computeRSI(List<double> prices, int period) {
    if (prices.length < period + 1) return 50.0;

    double avgGain = 0, avgLoss = 0;

    // Seed: first [period] changes
    for (int i = prices.length - period; i < prices.length; i++) {
      final delta = prices[i] - prices[i - 1];
      if (delta > 0) {
        avgGain += delta;
      } else {
        avgLoss += delta.abs();
      }
    }
    avgGain /= period;
    avgLoss /= period;

    if (avgLoss == 0) return 100.0;
    final rs = avgGain / avgLoss;
    return 100.0 - (100.0 / (1.0 + rs));
  }

  /// Exponential Moving Average
  static double _computeEMA(List<double> prices, int period) {
    if (prices.length < period) return prices.last;
    final k = 2.0 / (period + 1);
    double ema =
        prices.sublist(0, period).reduce((a, b) => a + b) / period;
    for (int i = period; i < prices.length; i++) {
      ema = prices[i] * k + ema * (1 - k);
    }
    return ema;
  }

  /// Bollinger Band Width = (Upper − Lower) / SMA
  static double _computeBBWidth(List<double> prices, int period) {
    if (prices.length < period) return 0.04;
    final slice = prices.sublist(prices.length - period);
    final sma = slice.reduce((a, b) => a + b) / period;
    final variance =
        slice.map((p) => (p - sma) * (p - sma)).reduce((a, b) => a + b) /
            period;
    final stdDev = sqrt(variance);
    return sma != 0 ? (2 * stdDev) / sma : 0.04;
  }

  // ─────────────────────────────────────────────
  //  Parsing / Mock Helpers
  // ─────────────────────────────────────────────
  static Stock _parseQuote(Map<String, dynamic> q, String ticker) {
    final change = _d(q['regularMarketChangePercent']);
    return Stock(
      name: q['shortName']?.toString() ??
          q['longName']?.toString() ??
          ticker,
      ticker: ticker,
      price: _d(q['regularMarketPrice']),
      change: change,
      riskLevel: _risk(change),
      status: _status(change),
      marketCap: _dn(q['marketCap']),
      peRatio: _dn(q['trailingPE']),
      volume: _dn(q['regularMarketVolume']),
      high52w: _dn(q['fiftyTwoWeekHigh']),
      low52w: _dn(q['fiftyTwoWeekLow']),
    );
  }

  static Future<Stock> _getWebMockQuote(String ticker) async {
    final r = Random();
    return Stock(
      name: '$ticker Inc.',
      ticker: ticker,
      price: 150.0 + r.nextDouble() * 50,
      change: (r.nextDouble() * 4) - 2,
      riskLevel: 'Medium',
      status: 'Stable growth',
      marketCap: 2.5e12,
      peRatio: 28.5,
      volume: 55000000,
      high52w: 210.0,
      low52w: 135.0,
    );
  }

  static List<PricePoint> _getWebMockHistory() {
    double p = 150.0;
    return List.generate(100, (i) {
      p += (Random().nextDouble() * 6) - 3;
      return PricePoint(
        date: DateTime.now().subtract(Duration(days: 100 - i)),
        close: p,
      );
    });
  }

  // ─────────────────────────────────────────────
  //  Tiny type converters
  // ─────────────────────────────────────────────
  static double _d(dynamic v) =>
      v != null ? (v as num).toDouble() : 0.0;
  static double? _dn(dynamic v) =>
      v != null ? (v as num).toDouble() : null;
  static List<double> _dl(dynamic v) =>
      (v as List? ?? []).map<double>((e) => _d(e)).toList();

  static String _risk(double c) =>
      c.abs() < 1.5 ? 'Low' : c.abs() < 4.0 ? 'Medium' : 'High';
  static String _status(double c) =>
      c > 1 ? 'Steady growth' : c < -1 ? 'Downward pressure' : 'Stable';
}