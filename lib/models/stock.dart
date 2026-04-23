// ============================================================
// FILE: lib/models/stock.dart
// ============================================================

class Stock {
  final int? id;
  final String name;
  final String ticker;
  final double price;
  final double change;        // percentage change
  final String riskLevel;     // "Low", "Medium", "High"
  final String status;        // human-readable summary
  final bool isInWatchlist;
  final double? marketCap;
  final double? peRatio;
  final double? volume;
  final double? high52w;
  final double? low52w;

  Stock({
    this.id,
    required this.name,
    required this.ticker,
    required this.price,
    required this.change,
    required this.riskLevel,
    required this.status,
    this.isInWatchlist = false,
    this.marketCap,
    this.peRatio,
    this.volume,
    this.high52w,
    this.low52w,
  });

  Stock copyWith({
    int? id,
    String? name,
    String? ticker,
    double? price,
    double? change,
    String? riskLevel,
    String? status,
    bool? isInWatchlist,
    double? marketCap,
    double? peRatio,
    double? volume,
    double? high52w,
    double? low52w,
  }) {
    return Stock(
      id: id ?? this.id,
      name: name ?? this.name,
      ticker: ticker ?? this.ticker,
      price: price ?? this.price,
      change: change ?? this.change,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      marketCap: marketCap ?? this.marketCap,
      peRatio: peRatio ?? this.peRatio,
      volume: volume ?? this.volume,
      high52w: high52w ?? this.high52w,
      low52w: low52w ?? this.low52w,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ticker': ticker,
      'price': price,
      'change': change,
      'riskLevel': riskLevel,
      'status': status,
      'isInWatchlist': isInWatchlist ? 1 : 0,
      'marketCap': marketCap,
      'peRatio': peRatio,
      'volume': volume,
      'high52w': high52w,
      'low52w': low52w,
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      name: map['name'],
      ticker: map['ticker'],
      price: (map['price'] as num).toDouble(),
      change: (map['change'] as num).toDouble(),
      riskLevel: map['riskLevel'],
      status: map['status'],
      isInWatchlist: map['isInWatchlist'] == 1,
      marketCap: map['marketCap'] != null ? (map['marketCap'] as num).toDouble() : null,
      peRatio: map['peRatio'] != null ? (map['peRatio'] as num).toDouble() : null,
      volume: map['volume'] != null ? (map['volume'] as num).toDouble() : null,
      high52w: map['high52w'] != null ? (map['high52w'] as num).toDouble() : null,
      low52w: map['low52w'] != null ? (map['low52w'] as num).toDouble() : null,
    );
  }
}