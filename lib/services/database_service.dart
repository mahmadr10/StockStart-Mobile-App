// ============================================================
// FILE: lib/services/database_service.dart
// ============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/stock.dart';
import '../models/trade.dart';

class DatabaseService {
  static Database? _db;
  static const double _initialBalance = 10000.0;

  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stockstart.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE stocks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            ticker TEXT NOT NULL UNIQUE,
            price REAL NOT NULL,
            change REAL NOT NULL,
            riskLevel TEXT NOT NULL,
            status TEXT NOT NULL,
            isInWatchlist INTEGER NOT NULL DEFAULT 0,
            marketCap REAL,
            peRatio REAL,
            volume REAL,
            high52w REAL,
            low52w REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE trades (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ticker TEXT NOT NULL,
            stockName TEXT NOT NULL,
            type TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            priceAtTrade REAL NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE portfolio (
            id INTEGER PRIMARY KEY,
            virtualBalance REAL NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE tips (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            category TEXT NOT NULL
          )
        ''');

        // Seed portfolio
        await db.insert('portfolio', {'id': 1, 'virtualBalance': _initialBalance});

        // Seed default stocks
        await _seedStocks(db);

        // Seed learning tips
        await _seedTips(db);
      },
    );
  }

  // ── STOCKS ──

  static Future<void> upsertStock(Stock stock) async {
    final db = await database;
    await db.insert(
      'stocks',
      stock.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Stock>> getAllStocks() async {
    final db = await database;
    final maps = await db.query('stocks');
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  static Future<List<Stock>> getWatchlistStocks() async {
    final db = await database;
    final maps = await db.query('stocks', where: 'isInWatchlist = ?', whereArgs: [1]);
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  static Future<List<Stock>> getStocksByRisk(String riskLevel) async {
    final db = await database;
    final maps = await db.query('stocks', where: 'riskLevel = ?', whereArgs: [riskLevel]);
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  static Future<void> toggleWatchlist(String ticker, bool value) async {
    final db = await database;
    await db.update(
      'stocks',
      {'isInWatchlist': value ? 1 : 0},
      where: 'ticker = ?',
      whereArgs: [ticker],
    );
  }

  static Future<void> updateStockPrice(String ticker, double price, double change) async {
    final db = await database;
    await db.update(
      'stocks',
      {'price': price, 'change': change},
      where: 'ticker = ?',
      whereArgs: [ticker],
    );
  }

  // ── PORTFOLIO / TRADING ──

  static Future<double> getVirtualBalance() async {
    final db = await database;
    final rows = await db.query('portfolio', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return _initialBalance;
    return (rows.first['virtualBalance'] as num).toDouble();
  }

  static Future<void> setVirtualBalance(double balance) async {
    final db = await database;
    await db.update('portfolio', {'virtualBalance': balance}, where: 'id = ?', whereArgs: [1]);
  }

  static Future<void> recordTrade(Trade trade) async {
    final db = await database;
    await db.insert('trades', trade.toMap());
  }

  static Future<List<Trade>> getAllTrades() async {
    final db = await database;
    final maps = await db.query('trades', orderBy: 'timestamp DESC');
    return maps.map((m) => Trade.fromMap(m)).toList();
  }

  static Future<Map<String, int>> getHoldings() async {
    final trades = await getAllTrades();
    final Map<String, int> holdings = {};
    for (final t in trades) {
      holdings[t.ticker] = (holdings[t.ticker] ?? 0) + (t.type == 'BUY' ? t.quantity : -t.quantity);
    }
    holdings.removeWhere((k, v) => v <= 0);
    return holdings;
  }

  // ── TIPS ──

  static Future<List<Map<String, dynamic>>> getAllTips() async {
    final db = await database;
    return db.query('tips');
  }

  static Future<Map<String, dynamic>?> getDailyTip() async {
    final db = await database;
    final tips = await db.query('tips');
    if (tips.isEmpty) return null;
    final dayIndex = DateTime.now().day % tips.length;
    return tips[dayIndex];
  }

  // ── SEED DATA ──

  static Future<void> _seedStocks(Database db) async {
    final stocks = [
      {'name': 'Apple Inc.', 'ticker': 'AAPL', 'price': 189.30, 'change': 1.2, 'riskLevel': 'Low', 'status': 'Steady growth trend', 'isInWatchlist': 1},
      {'name': 'NVIDIA Corp.', 'ticker': 'NVDA', 'price': 875.40, 'change': 3.8, 'riskLevel': 'High', 'status': 'Strong upward momentum', 'isInWatchlist': 1},
      {'name': 'Microsoft Corp.', 'ticker': 'MSFT', 'price': 415.20, 'change': 0.9, 'riskLevel': 'Low', 'status': 'Stable, low volatility', 'isInWatchlist': 0},
      {'name': 'Tesla Inc.', 'ticker': 'TSLA', 'price': 172.50, 'change': -2.1, 'riskLevel': 'High', 'status': 'Slight decline observed', 'isInWatchlist': 1},
      {'name': 'Amazon.com', 'ticker': 'AMZN', 'price': 185.10, 'change': 1.5, 'riskLevel': 'Medium', 'status': 'Steady growth trend', 'isInWatchlist': 0},
      {'name': 'Alphabet Inc.', 'ticker': 'GOOGL', 'price': 162.80, 'change': 0.7, 'riskLevel': 'Low', 'status': 'Stable, low volatility', 'isInWatchlist': 0},
      {'name': 'Meta Platforms', 'ticker': 'META', 'price': 485.90, 'change': 2.3, 'riskLevel': 'Medium', 'status': 'Moderate uptrend', 'isInWatchlist': 0},
      {'name': 'Berkshire Hathaway', 'ticker': 'BRK-B', 'price': 395.60, 'change': 0.3, 'riskLevel': 'Low', 'status': 'Very stable growth', 'isInWatchlist': 0},
      {'name': 'Coinbase Global', 'ticker': 'COIN', 'price': 212.40, 'change': 5.1, 'riskLevel': 'High', 'status': 'High volatility period', 'isInWatchlist': 0},
      {'name': 'Palantir Tech.', 'ticker': 'PLTR', 'price': 22.80, 'change': 4.2, 'riskLevel': 'High', 'status': 'Rapid short-term rise', 'isInWatchlist': 0},
    ];
    for (final s in stocks) {
      await db.insert('stocks', {...s, 'id': null, 'marketCap': null, 'peRatio': null, 'volume': null, 'high52w': null, 'low52w': null});
    }
  }

  static Future<void> _seedTips(Database db) async {
    final tips = [
      {'title': 'Diversify Your Portfolio', 'body': 'Spreading investments across different sectors reduces risk. Don\'t put all eggs in one basket.', 'category': 'Risk Management'},
      {'title': 'Understand P/E Ratio', 'body': 'Price-to-Earnings ratio compares a stock\'s price to its earnings. Lower P/E can indicate undervaluation.', 'category': 'Fundamentals'},
      {'title': 'Dollar-Cost Averaging', 'body': 'Invest a fixed amount regularly regardless of price. This smooths out market volatility over time.', 'category': 'Strategy'},
      {'title': 'RSI Indicator', 'body': 'RSI above 70 suggests a stock may be overbought. Below 30 suggests oversold. It measures momentum.', 'category': 'Technical Analysis'},
      {'title': 'What is Market Cap?', 'body': 'Market Cap = Share Price × Total Shares. It reflects the total market value of a company.', 'category': 'Fundamentals'},
      {'title': 'MACD Explained', 'body': 'MACD shows trend direction and momentum. A positive MACD Diff signals bullish momentum.', 'category': 'Technical Analysis'},
      {'title': 'Bollinger Bands', 'body': 'When bands are narrow (low BB Width), volatility is low. Wide bands signal high market uncertainty.', 'category': 'Technical Analysis'},
    ];
    for (final t in tips) {
      await db.insert('tips', t);
    }
  }
}