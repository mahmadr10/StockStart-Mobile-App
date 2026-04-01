// ============================================================
// FILE: lib/database/database_helper.dart
// PURPOSE: Creates the database, the table, and all functions
//          to get/save/update stocks.
// ============================================================
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockstart/models/stock.dart';

class DatabaseHelper {
  // Singleton pattern — only ONE instance of the database exists
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Gets the database (creates it if it doesn't exist yet)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stockstart.db');
    return _database!;
  }

  // Creates the database file and the stocks table
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // This runs ONCE when the app is installed — creates the table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stocks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        ticker TEXT NOT NULL,
        price REAL NOT NULL,
        change REAL NOT NULL,
        riskLevel TEXT NOT NULL,
        status TEXT NOT NULL,
        isInWatchlist INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Pre-fill with 8 sample stocks
    await _insertSampleData(db);
  }

  // Sample stocks — added automatically on first launch
  Future<void> _insertSampleData(Database db) async {
    final sampleStocks = [
      {'name': 'TechCorp',     'ticker': 'TCC', 'price': 150.25, 'change': 12.5,  'riskLevel': 'Medium', 'status': 'Steady growth',   'isInWatchlist': 1},
      {'name': 'HealthInc',    'ticker': 'HLT', 'price': 205.75, 'change': -2.3,  'riskLevel': 'Low',    'status': 'Stable',           'isInWatchlist': 1},
      {'name': 'EnergyCo',     'ticker': 'ENG', 'price': 88.50,  'change': 5.1,   'riskLevel': 'High',   'status': 'Volatile',         'isInWatchlist': 1},
      {'name': 'SafeInvest',   'ticker': 'SFI', 'price': 120.50, 'change': 1.2,   'riskLevel': 'Low',    'status': 'Growing steadily', 'isInWatchlist': 1},
      {'name': 'SteadyGrowth', 'ticker': 'STG', 'price': 380.75, 'change': 3.4,   'riskLevel': 'Low',    'status': 'Stable growth',    'isInWatchlist': 1},
      {'name': 'CryptoRush',   'ticker': 'CRX', 'price': 45.00,  'change': -18.7, 'riskLevel': 'High',   'status': 'Very volatile',    'isInWatchlist': 0},
      {'name': 'MediPlus',     'ticker': 'MDP', 'price': 310.00, 'change': 0.8,   'riskLevel': 'Low',    'status': 'Slow but safe',    'isInWatchlist': 0},
      {'name': 'AutoDrive',    'ticker': 'ADV', 'price': 220.30, 'change': 9.2,   'riskLevel': 'Medium', 'status': 'Growing fast',     'isInWatchlist': 0},
    ];

    for (final stock in sampleStocks) {
      await db.insert('stocks', stock);
    }
  }

  // ─── DATABASE FUNCTIONS ───────────────────────────────────────

  // Get ALL stocks
  Future<List<Stock>> getAllStocks() async {
    final db = await database;
    final maps = await db.query('stocks');
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  // Get only watchlist stocks
  Future<List<Stock>> getWatchlistStocks() async {
    final db = await database;
    final maps = await db.query(
      'stocks',
      where: 'isInWatchlist = ?',
      whereArgs: [1],
    );
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  // Get watchlist filtered by risk level
  Future<List<Stock>> getWatchlistByRisk(String risk) async {
    final db = await database;
    final maps = await db.query(
      'stocks',
      where: 'isInWatchlist = ? AND riskLevel = ?',
      whereArgs: [1, risk],
    );
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  // Search stocks by name or ticker
  Future<List<Stock>> searchStocks(String query) async {
    final db = await database;
    final maps = await db.query(
      'stocks',
      where: 'name LIKE ? OR ticker LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  // Update a stock (e.g. toggle watchlist)
  Future<void> updateStock(Stock stock) async {
    final db = await database;
    await db.update(
      'stocks',
      stock.toMap(),
      where: 'id = ?',
      whereArgs: [stock.id],
    );
  }

  // Insert a new stock
  Future<void> insertStock(Stock stock) async {
    final db = await database;
    await db.insert('stocks', stock.toMap());
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
