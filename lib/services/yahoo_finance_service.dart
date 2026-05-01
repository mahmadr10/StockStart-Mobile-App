// lib/services/yahoo_finance_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/prediction_result.dart';

class YahooFinanceService {
  static const _quoteBase = 'https://query2.finance.yahoo.com/v7/finance/quote';
  static const _chartBase = 'https://query2.finance.yahoo.com/v8/finance/chart';
  
  static const _hdrs  = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Connection': 'keep-alive',
  };

  // ── Single Quote ──
  static Future<Stock?> fetchQuote(String ticker) async {
    final list = await fetchQuotes([ticker]);
    return list.isNotEmpty ? list.first : null;
  }

  // ── Batch Quotes ──
  static Future<List<Stock>> fetchQuotes(List<String> tickers) async {
    if (tickers.isEmpty) return [];
    final symbols = tickers.map((e) => e.toUpperCase().trim()).join(',');
    try {
      final uri = Uri.parse(
        '$_quoteBase?symbols=$symbols'
            '&fields=shortName,longName,regularMarketPrice,regularMarketChangePercent,'
            'marketCap,trailingPE,regularMarketVolume,fiftyTwoWeekHigh,fiftyTwoWeekLow',
      );
      final res = await http.get(uri, headers: _hdrs)
          .timeout(const Duration(seconds: 10));
      
      if (res.statusCode == 200) {
        final data   = jsonDecode(res.body);
        final result = data['quoteResponse']?['result'] as List?;
        if (result != null && result.isNotEmpty) {
          return result.map((q) {
            final t = q['symbol']?.toString() ?? '';
            final change = _d(q['regularMarketChangePercent']);
            return Stock(
              name:      q['shortName']?.toString() ?? q['longName']?.toString() ?? t,
              ticker:    t,
              price:     _d(q['regularMarketPrice']),
              change:    change,
              riskLevel: _risk(change),
              status:    _status(change),
              marketCap: _dn(q['marketCap']),
              peRatio:   _dn(q['trailingPE']),
              volume:    _dn(q['regularMarketVolume']),
              high52w:   _dn(q['fiftyTwoWeekHigh']),
              low52w:    _dn(q['fiftyTwoWeekLow']),
            );
          }).toList();
        }
      }
      
      // If batch fails and it's just one ticker, try chart fallback
      if (tickers.length == 1) {
        final fallback = await _fetchFromChart(tickers.first);
        return fallback != null ? [fallback] : [];
      }
      return [];
    } catch (_) {
      if (tickers.length == 1) {
        final fallback = await _fetchFromChart(tickers.first);
        return fallback != null ? [fallback] : [];
      }
      return [];
    }
  }

  static Future<Stock?> _fetchFromChart(String ticker) async {
    try {
      final uri = Uri.parse('$_chartBase/$ticker?interval=1d&range=1d');
      final res = await http.get(uri, headers: _hdrs)
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;
      
      final data = jsonDecode(res.body);
      final result = data['chart']?['result'] as List?;
      if (result == null || result.isEmpty) return null;
      
      final meta = result[0]['meta'];
      final price = _d(meta['regularMarketPrice']);
      final prevClose = _d(meta['chartPreviousClose'] ?? price);
      final change = prevClose != 0 ? ((price - prevClose) / prevClose) * 100 : 0.0;
      
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

  // ── History ──
  static Future<List<PricePoint>> fetchHistory(
      String ticker, {
        String interval = '1d',
        String range    = '1y',
      }) async {
    try {
      final uri = Uri.parse('$_chartBase/$ticker?interval=$interval&range=$range');
      final res = await http.get(uri, headers: _hdrs)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      final data  = jsonDecode(res.body);
      final chart = (data['chart']?['result'] as List?);
      if (chart == null || chart.isEmpty) return [];
      final r0      = chart[0] as Map<String, dynamic>;
      final ts      = List<int>.from(r0['timestamp'] as List? ?? []);
      
      final indicatorsList = r0['indicators']?['quote'] as List?;
      if (indicatorsList == null || indicatorsList.isEmpty) return [];
      
      final q0      = indicatorsList[0] as Map<String, dynamic>? ?? {};
      final closes  = _dl(q0['close']);
      final opens   = _dl(q0['open']);
      final highs   = _dl(q0['high']);
      final lows    = _dl(q0['low']);
      final volumes = _dl(q0['volume']);
      final out = <PricePoint>[];
      for (int i = 0; i < ts.length && i < closes.length; i++) {
        if (closes[i] > 0) {
          out.add(PricePoint(
            date:   DateTime.fromMillisecondsSinceEpoch(ts[i] * 1000),
            close:  closes[i],
            open:   i < opens.length   ? opens[i]   : null,
            high:   i < highs.length   ? highs[i]   : null,
            low:    i < lows.length    ? lows[i]    : null,
            volume: i < volumes.length ? volumes[i] : null,
          ));
        }
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  // ── Prediction ──
  static PredictionResult computePrediction(List<PricePoint> history) {
    if (history.length < 50) {
      return PredictionResult(
        trendDirection: 'N/A', trendConfidence: 0,
        predictedPrice: history.isNotEmpty ? history.last.close : 0,
        rmseEstimate: 0, rsi: 50, macdDiff: 0,
        distFromSma: 0, bbWidth: 0,
        signalStrength: 'Insufficient Data',
      );
    }
    final cl    = history.map((p) => p.close).toList();
    final rsi   = _rsi(cl, 14);
    final sma50 = cl.sublist(cl.length - 50).reduce((a, b) => a + b) / 50;
    final dist  = cl.last - sma50;
    final macd  = _ema(cl, 12) - _ema(cl, 26);
    final bb20  = cl.sublist(cl.length - 20);
    final bbMean = bb20.reduce((a, b) => a + b) / 20;
    final bbStd  = _std(bb20);
    final bbW    = bbMean == 0 ? 0.0 : (4 * bbStd) / bbMean;

    double score = 0;
    if (rsi > 30 && rsi < 70) score += 0.25;
    if (macd > 0)              score += 0.35;
    if (dist > 0)              score += 0.25;
    if (bbW < 0.05)            score += 0.15;

    final up   = score >= 0.5;
    final conf = up ? score : (1 - score);
    final slope = (cl.last - cl[cl.length - 5]) / 5;
    final pred  = cl.last + slope;

    double rmseSum = 0;
    for (int i = cl.length - 10; i < cl.length - 1; i++) {
      final e = cl[i + 1] - cl[i];
      rmseSum += e * e;
    }
    final rmse = sqrt(rmseSum / 9);

    return PredictionResult(
      trendDirection: up ? 'UP' : 'DOWN',
      trendConfidence: conf,
      predictedPrice: pred,
      rmseEstimate: rmse > 0 ? rmse : 1.0,
      rsi: rsi, macdDiff: macd,
      distFromSma: dist, bbWidth: bbW,
      signalStrength: conf > 0.75 ? 'Strong' : conf > 0.55 ? 'Moderate' : 'Weak',
    );
  }

  // ── Helpers ──
  static double _d(dynamic v)  => v != null ? (v as num).toDouble() : 0.0;
  static double? _dn(dynamic v) => v != null ? (v as num).toDouble() : null;
  static List<double> _dl(dynamic v) =>
      (v as List? ?? [])
          .map<double>((e) => e != null ? (e as num).toDouble() : 0.0)
          .toList();

  static double _rsi(List<double> p, int period) {
    if (p.length < period + 1) return 50.0;
    double g = 0, l = 0;
    for (int i = p.length - period; i < p.length; i++) {
      final d = p[i] - p[i - 1];
      if (d > 0) g += d; else l += d.abs();
    }
    if (l == 0) return 100.0;
    return 100 - (100 / (1 + g / l));
  }

  static double _ema(List<double> p, int period) {
    if (p.length < period) return p.last;
    final k = 2.0 / (period + 1);
    double e = p.sublist(0, period).reduce((a, b) => a + b) / period;
    for (int i = period; i < p.length; i++) e = p[i] * k + e * (1 - k);
    return e;
  }

  static double _std(List<double> d) {
    final m = d.reduce((a, b) => a + b) / d.length;
    final v = d.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b) / d.length;
    return v > 0 ? sqrt(v) : 0.0;
  }

  static String _risk(double c) {
    final a = c.abs();
    if (a < 1.5) return 'Low';
    if (a < 4.0) return 'Medium';
    return 'High';
  }

  static String _status(double c) {
    if (c >  3) return 'Strong upward momentum';
    if (c >  1) return 'Steady growth trend';
    if (c > -1) return 'Stable, low volatility';
    if (c > -3) return 'Slight decline observed';
    return 'Significant downward pressure';
  }
}
