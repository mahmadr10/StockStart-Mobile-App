// ============================================================
// FILE: lib/models/trade.dart
// ============================================================

class Trade {
  final int? id;
  final String ticker;
  final String stockName;
  final String type;       // "BUY" or "SELL"
  final int quantity;
  final double priceAtTrade;
  final DateTime timestamp;

  Trade({
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

  factory Trade.fromMap(Map<String, dynamic> map) => Trade(
    id: map['id'],
    ticker: map['ticker'],
    stockName: map['stockName'],
    type: map['type'],
    quantity: map['quantity'],
    priceAtTrade: (map['priceAtTrade'] as num).toDouble(),
    timestamp: DateTime.parse(map['timestamp']),
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