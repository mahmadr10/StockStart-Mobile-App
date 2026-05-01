// lib/services/database_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/stock.dart';
import '../models/trade.dart';

class DatabaseService {
  static Database? _db;
  static const double _startBalance = 10000.0;

  // Web Mocks (Since sqflite doesn't support Chrome)
  static List<Stock>? _webStocks;
  static double?      _webBalance;
  static List<Trade>  _webTrades = [];
  static Map<String, String> _webUsers = {"admin": "123456"};

  static Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    if (kIsWeb) return openDatabase(inMemoryDatabasePath);
    final dir = await getDatabasesPath();
    final path = join(dir, 'stockstart_v5.db');
    return await openDatabase(path, version: 1, onCreate: _create);
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT)');
    await db.execute('CREATE TABLE stocks (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, ticker TEXT UNIQUE, price REAL, change REAL, riskLevel TEXT, status TEXT, isInWatchlist INTEGER DEFAULT 0, marketCap REAL, peRatio REAL, volume REAL, high52w REAL, low52w REAL)');
    await db.execute('CREATE TABLE trades (id INTEGER PRIMARY KEY AUTOINCREMENT, ticker TEXT, stockName TEXT, type TEXT, quantity INTEGER, priceAtTrade REAL, timestamp TEXT)');
    await db.execute('CREATE TABLE portfolio (id INTEGER PRIMARY KEY, virtualBalance REAL)');
    await db.execute('CREATE TABLE tips (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, category TEXT)');

    await db.insert('portfolio', {'id': 1, 'virtualBalance': _startBalance});
    await _seedStocks(db);
    await _seedTips(db);
  }

  // ── AUTH ─────────────────────────────────────────────────
  static Future<String?> signUp(String username, String password) async {
    if (kIsWeb) {
      if (_webUsers.containsKey(username)) return 'Username taken.';
      _webUsers[username] = password;
      return null;
    }
    try {
      final db = await _database;
      await db.insert('users', {'username': username, 'password': password});
      return null;
    } catch (e) { return 'Username already exists.'; }
  }

  static Future<String?> login(String username, String password) async {
    if (kIsWeb) {
      if (_webUsers[username] == password) return null;
      return 'Invalid credentials.';
    }
    final db = await _database;
    final res = await db.query('users', where: 'username=? AND password=?', whereArgs: [username, password]);
    return res.isEmpty ? 'Invalid credentials.' : null;
  }

  // ── STOCKS ────────────────────────────────────────────────
  static Future<void> upsertStock(Stock s) async {
    if (kIsWeb) {
      final stocks = await getAllStocks();
      int i = stocks.indexWhere((x) => x.ticker == s.ticker);
      if (i != -1) _webStocks![i] = s; else _webStocks!.add(s);
      return;
    }
    final db = await _database;
    await db.insert('stocks', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Stock>> getAllStocks() async {
    if (kIsWeb) return _webStocks ??= _getSeedData();
    final db = await _database;
    final res = await db.query('stocks');
    return res.map(Stock.fromMap).toList();
  }

  static Future<List<Stock>> getWatchlistByRisk(String risk) async {
    final all = await getAllStocks();
    return all.where((s) => s.isInWatchlist && s.riskLevel == risk).toList();
  }

  static Future<List<Stock>> getWatchlistStocks() async {
    final all = await getAllStocks();
    return all.where((s) => s.isInWatchlist).toList();
  }

  static Future<void> toggleWatchlist(String ticker, bool val) async {
    if (kIsWeb) {
      final stocks = await getAllStocks();
      int i = stocks.indexWhere((s) => s.ticker == ticker);
      if (i != -1) _webStocks![i] = stocks[i].copyWith(isInWatchlist: val);
      return;
    }
    final db = await _database;
    await db.update('stocks', {'isInWatchlist': val ? 1 : 0}, where: 'ticker=?', whereArgs: [ticker.toUpperCase()]);
  }

  // ── TRADING ──────────────────────────────────────────────
  static Future<double> getVirtualBalance() async {
    if (kIsWeb) return _webBalance ?? _startBalance;
    final db = await _database;
    final res = await db.query('portfolio', where: 'id=1');
    return res.isEmpty ? _startBalance : (res.first['virtualBalance'] as num).toDouble();
  }

  static Future<void> setVirtualBalance(double b) async {
    if (kIsWeb) { _webBalance = b; return; }
    final db = await _database;
    await db.update('portfolio', {'virtualBalance': b}, where: 'id=1');
  }

  static Future<void> recordTrade(Trade t) async {
    if (kIsWeb) { _webTrades.insert(0, t); return; }
    final db = await _database;
    await db.insert('trades', t.toMap());
  }

  static Future<List<Trade>> getAllTrades() async {
    if (kIsWeb) return _webTrades;
    final db = await _database;
    final res = await db.query('trades', orderBy: 'timestamp DESC');
    return res.map(Trade.fromMap).toList();
  }

  static Future<Map<String, int>> getHoldings() async {
    final trades = await getAllTrades();
    Map<String, int> h = {};
    for (var t in trades) {
      h[t.ticker] = (h[t.ticker] ?? 0) + (t.type == 'BUY' ? t.quantity : -t.quantity);
    }
    h.removeWhere((k, v) => v <= 0);
    return h;
  }

  // ── TIPS ──
  static Future<List<Map<String, dynamic>>> getAllTips() async {
    if (kIsWeb) return [{'id': 1, 'title': 'Diversify', 'body': 'Spread your risk.', 'category': 'Risk'}];
    final db = await _database;
    return await db.query('tips');
  }

  static Future<Map<String, dynamic>?> getDailyTip() async {
    final tips = await getAllTips();
    return tips.isEmpty ? null : tips[DateTime.now().day % tips.length];
  }

  static List<Stock> _getSeedData() {
    return [
      const Stock(name: 'Apple Inc.', ticker: 'AAPL', price: 189.30, change: 1.2, riskLevel: 'Low', status: 'Growth', isInWatchlist: true),
      const Stock(name: 'NVIDIA', ticker: 'NVDA', price: 875.40, change: 3.8, riskLevel: 'High', status: 'Momentum', isInWatchlist: true),
      const Stock(name: 'Tesla', ticker: 'TSLA', price: 172.50, change: -2.1, riskLevel: 'High', status: 'Volatile', isInWatchlist: true),
    ];
  }

  static Future<void> _seedStocks(Database db) async {
    for (var s in _getSeedData()) await db.insert('stocks', s.toMap());
  }

  static Future<void> _seedTips(Database db) async {
    await db.insert('tips', {'title': 'Diversify', 'body': 'Spread your risk.', 'category': 'Risk'});
  }
}