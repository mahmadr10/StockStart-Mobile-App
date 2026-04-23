// ============================================================
// FILE: lib/services/yahoo_finance_service.dart
// PURPOSE: Fetch real stock data from Yahoo Finance API
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/prediction_result.dart';

class YahooFinanceService {
  static const String _baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart';
  static const String _quoteUrl = 'https://query1.finance.yahoo.com/v7/finance/quote';

  // ── Fetch quote summary (price, change, marketCap, etc.) ──
  static Future<Stock?> fetchQuote(String ticker) async {
    try {
      final uri = Uri.parse(
        '$_quoteUrl?symbols=$ticker&fields=shortName,regularMarketPrice,regularMarketChangePercent,marketCap,trailingPE,regularMarketVolume,fiftyTwoWeekHigh,fiftyTwoWeekLow',
      );
      final response = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final result = data['quoteResponse']['result'];
      if (result == null || result.isEmpty) return null;

      final q = result[0];
      final price = (q['regularMarketPrice'] ?? 0.0).toDouble();
      final changePct = (q['regularMarketChangePercent'] ?? 0.0).toDouble();
      final marketCap = q['marketCap'] != null ? (q['marketCap'] as num).toDouble() : null;
      final pe = q['trailingPE'] != null ? (q['trailingPE'] as num).toDouble() : null;
      final vol = q['regularMarketVolume'] != null ? (q['regularMarketVolume'] as num).toDouble() : null;
      final high52 = q['fiftyTwoWeekHigh'] != null ? (q['fiftyTwoWeekHigh'] as num).toDouble() : null;
      final low52 = q['fiftyTwoWeekLow'] != null ? (q['fiftyTwoWeekLow'] as num).toDouble() : null;

      return Stock(
        name: q['shortName'] ?? ticker,
        ticker: ticker.toUpperCase(),
        price: price,
        change: changePct,
        riskLevel: _inferRiskLevel(changePct, vol),
        status: _generateStatus(changePct),
        marketCap: marketCap,
        peRatio: pe,
        volume: vol,
        high52w: high52,
        low52w: low52,
      );
    } catch (e) {
      return null;
    }
  }

  // ── Fetch historical OHLCV price data ──
  static Future<List<PricePoint>> fetchHistory(
      String ticker, {
        String interval = '1d',
        String range = '1y',
      }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/$ticker?interval=$interval&range=$range',
      );
      final response = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final chart = data['chart']['result'];
      if (chart == null || chart.isEmpty) return [];

      final timestamps = List<int>.from(chart[0]['timestamp'] ?? []);
      final closes = List<double>.from(
        (chart[0]['indicators']['quote'][0]['close'] ?? []).map((e) => (e ?? 0).toDouble()),
      );
      final opens = List<double>.from(
        (chart[0]['indicators']['quote'][0]['open'] ?? []).map((e) => (e ?? 0).toDouble()),
      );
      final highs = List<double>.from(
        (chart[0]['indicators']['quote'][0]['high'] ?? []).map((e) => (e ?? 0).toDouble()),
      );
      final lows = List<double>.from(
        (chart[0]['indicators']['quote'][0]['low'] ?? []).map((e) => (e ?? 0).toDouble()),
      );
      final volumes = List<double>.from(
        (chart[0]['indicators']['quote'][0]['volume'] ?? []).map((e) => (e ?? 0).toDouble()),
      );

      final points = <PricePoint>[];
      for (int i = 0; i < timestamps.length; i++) {
        if (closes[i] > 0) {
          points.add(PricePoint(
            date: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
            close: closes[i],
            open: opens.length > i ? opens[i] : null,
            high: highs.length > i ? highs[i] : null,
            low: lows.length > i ? lows[i] : null,
            volume: volumes.length > i ? volumes[i] : null,
          ));
        }
      }
      return points;
    } catch (e) {
      return [];
    }
  }

  // ── Compute technical indicators + simple prediction ──
  static PredictionResult computePrediction(List<PricePoint> history) {
    if (history.length < 50) {
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

    final closes = history.map((p) => p.close).toList();

    // RSI (14)
    final rsi = _computeRSI(closes, 14);

    // SMA 50
    final sma50 = closes.sublist(closes.length - 50).reduce((a, b) => a + b) / 50;
    final distFromSma = closes.last - sma50;

    // MACD (12, 26, 9)
    final ema12 = _computeEMA(closes, 12);
    final ema26 = _computeEMA(closes, 26);
    final macdLine = ema12 - ema26;
    final macdDiff = macdLine; // simplified

    // Bollinger Bands (20)
    final bb20 = closes.sublist(closes.length - 20);
    final bbMean = bb20.reduce((a, b) => a + b) / 20;
    final bbStd = _std(bb20);
    final bbWidth = bbStd == 0 ? 0.0 : (4 * bbStd) / bbMean;

    // ── Simple rule-based classification (mirrors Streamlit logic) ──
    // Features: RSI, MACD_Diff, Dist_from_SMA, BB_Width
    double score = 0;
    if (rsi < 70 && rsi > 30) score += 0.25;       // not overbought/oversold
    if (macdDiff > 0) score += 0.35;               // bullish momentum
    if (distFromSma > 0) score += 0.25;            // above SMA
    if (bbWidth < 0.05) score += 0.15;             // low volatility = stability

    final trendUp = score >= 0.5;
    final trendDir = trendUp ? 'UP' : 'DOWN';
    final confidence = trendUp ? score : (1 - score);

    // ── Simple regression: SMA-based next-price estimate ──
    final recentSlope = (closes.last - closes[closes.length - 5]) / 5;
    final predictedPrice = closes.last + recentSlope;

    // RMSE estimate using recent rolling errors
    double rmseSum = 0;
    for (int i = closes.length - 10; i < closes.length - 1; i++) {
      final err = closes[i + 1] - closes[i];
      rmseSum += err * err;
    }
    final rmse = (rmseSum / 9) > 0 ? (rmseSum / 9) : 1.0;

    // Signal strength
    String strength;
    if (confidence > 0.75) {
      strength = 'Strong';
    } else if (confidence > 0.55) {
      strength = 'Moderate';
    } else {
      strength = 'Weak';
    }

    return PredictionResult(
      trendDirection: trendDir,
      trendConfidence: confidence,
      predictedPrice: predictedPrice,
      rmseEstimate: rmse,
      rsi: rsi,
      macdDiff: macdDiff,
      distFromSma: distFromSma,
      bbWidth: bbWidth,
      signalStrength: strength,
    );
  }

  // ── Batch fetch multiple tickers ──
  static Future<List<Stock>> fetchMultipleQuotes(List<String> tickers) async {
    final results = <Stock>[];
    for (final ticker in tickers) {
      final stock = await fetchQuote(ticker);
      if (stock != null) results.add(stock);
    }
    return results;
  }

  // ── Helpers ──

  static double _computeRSI(List<double> prices, int period) {
    if (prices.length < period + 1) return 50.0;
    double gains = 0, losses = 0;
    for (int i = prices.length - period; i < prices.length; i++) {
      final diff = prices[i] - prices[i - 1];
      if (diff > 0) gains += diff;
      else losses += diff.abs();
    }
    if (losses == 0) return 100.0;
    final rs = gains / losses;
    return 100 - (100 / (1 + rs));
  }

  static double _computeEMA(List<double> prices, int period) {
    if (prices.length < period) return prices.last;
    final k = 2.0 / (period + 1);
    double ema = prices.sublist(0, period).reduce((a, b) => a + b) / period;
    for (int i = period; i < prices.length; i++) {
      ema = prices[i] * k + ema * (1 - k);
    }
    return ema;
  }

  static double _std(List<double> data) {
    final mean = data.reduce((a, b) => a + b) / data.length;
    final variance = data.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / data.length;
    return variance > 0 ? variance : 0;
  }

  static String _inferRiskLevel(double changePct, double? volume) {
    final absChange = changePct.abs();
    if (absChange < 1.5) return 'Low';
    if (absChange < 4.0) return 'Medium';
    return 'High';
  }

  static String _generateStatus(double changePct) {
    if (changePct > 3) return 'Strong upward momentum';
    if (changePct > 1) return 'Steady growth trend';
    if (changePct > -1) return 'Stable, low volatility';
    if (changePct > -3) return 'Slight decline observed';
    return 'Significant downward pressure';
  }
}