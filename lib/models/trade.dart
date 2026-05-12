// lib/models/trade.dart
class Trade {
  final int?     id;
  final String   ticker;
  final String   stockName;
  final String   type;        // "BUY" | "SELL"
  final int      quantity;
  final double   priceAtTrade;
  final DateTime timestamp;

  const Trade({
    this.id,
    required this.ticker,
    required this.stockName,
    required this.type,
    required this.quantity,
    required this.priceAtTrade,
    required this.timestamp,
  });

  double get totalValue => quantity * priceAtTrade;

  Map<String, dynamic> toMap() => {
    'id': id,
    'ticker': ticker,
    'stockName': stockName,
    'type': type,
    'quantity': quantity,
    'priceAtTrade': priceAtTrade,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Trade.fromMap(Map<String, dynamic> m) => Trade(
    id:           m['id'] as int?,
    ticker:       m['ticker']      as String,
    stockName:    m['stockName']   as String,
    type:         m['type']        as String,
    quantity:     m['quantity']    as int,
    priceAtTrade: (m['priceAtTrade'] as num).toDouble(),
    timestamp:    DateTime.parse(m['timestamp'] as String),
  );
}

class Portfolio {
  final Map<String, int> holdings;   // ticker -> quantity
  final double virtualBalance;
  final double initialBalance;

  Portfolio({
    required this.holdings,
    required this.virtualBalance,
    this.initialBalance = 10000.0,
  });

  double get totalInvested => initialBalance - virtualBalance;
}