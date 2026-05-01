// lib/models/stock.dart
class Stock {
  final int?    id;
  final String  name;
  final String  ticker;
  final double  price;
  final double  change;
  final String  riskLevel;
  final String  status;
  final bool    isInWatchlist;
  final double? marketCap;
  final double? peRatio;
  final double? volume;
  final double? high52w;
  final double? low52w;

  const Stock({
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
    int?    id,    String? name,    String? ticker,
    double? price, double? change,  String? riskLevel,
    String? status, bool?  isInWatchlist,
    double? marketCap, double? peRatio, double? volume,
    double? high52w,   double? low52w,
  }) => Stock(
    id:            id            ?? this.id,
    name:          name          ?? this.name,
    ticker:        ticker        ?? this.ticker,
    price:         price         ?? this.price,
    change:        change        ?? this.change,
    riskLevel:     riskLevel     ?? this.riskLevel,
    status:        status        ?? this.status,
    isInWatchlist: isInWatchlist ?? this.isInWatchlist,
    marketCap:     marketCap     ?? this.marketCap,
    peRatio:       peRatio       ?? this.peRatio,
    volume:        volume        ?? this.volume,
    high52w:       high52w       ?? this.high52w,
    low52w:        low52w        ?? this.low52w,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'ticker': ticker,
    'price': price, 'change': change,
    'riskLevel': riskLevel, 'status': status,
    'isInWatchlist': isInWatchlist ? 1 : 0,
    'marketCap': marketCap, 'peRatio': peRatio,
    'volume': volume, 'high52w': high52w, 'low52w': low52w,
  };

  factory Stock.fromMap(Map<String, dynamic> m) => Stock(
    id:            m['id'] as int?,
    name:          m['name']     as String? ?? '',
    ticker:        m['ticker']   as String? ?? '',
    price:         (m['price']   as num?    ?? 0).toDouble(),
    change:        (m['change']  as num?    ?? 0).toDouble(),
    riskLevel:     m['riskLevel'] as String? ?? 'Low',
    status:        m['status']   as String? ?? '',
    isInWatchlist: (m['isInWatchlist'] as int? ?? 0) == 1,
    marketCap:     m['marketCap']  != null ? (m['marketCap']  as num).toDouble() : null,
    peRatio:       m['peRatio']    != null ? (m['peRatio']    as num).toDouble() : null,
    volume:        m['volume']     != null ? (m['volume']     as num).toDouble() : null,
    high52w:       m['high52w']    != null ? (m['high52w']    as num).toDouble() : null,
    low52w:        m['low52w']     != null ? (m['low52w']     as num).toDouble() : null,
  );
}