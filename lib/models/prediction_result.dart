// lib/models/prediction_result.dart
class PredictionResult {
  final String trendDirection;   // "UP" | "DOWN" | "N/A"
  final double trendConfidence;  // 0.0 – 1.0
  final double predictedPrice;
  final double rmseEstimate;
  final double rsi;
  final double macdDiff;
  final double distFromSma;
  final double bbWidth;
  final String signalStrength;   // "Strong" | "Moderate" | "Weak"

  const PredictionResult({
    required this.trendDirection,
    required this.trendConfidence,
    required this.predictedPrice,
    required this.rmseEstimate,
    required this.rsi,
    required this.macdDiff,
    required this.distFromSma,
    required this.bbWidth,
    required this.signalStrength,
  });
}

class PricePoint {
  final DateTime date;
  final double   close;
  final double?  open;
  final double?  high;
  final double?  low;
  final double?  volume;

  const PricePoint({
    required this.date,
    required this.close,
    this.open, this.high, this.low, this.volume,
  });
}