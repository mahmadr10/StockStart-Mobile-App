import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockstart/models/stock.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stockstart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

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

    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final sampleStocks = [
      {'name': 'TechCorp', 'ticker': 'TCC', 'price': 150.25, 'change': 12.5, 'riskLevel': 'Medium', 'status': 'Steady growth', 'isInWatchlist': 1},
      {'name': 'HealthInc', 'ticker': 'HLT', 'price': 205.75, 'change': -2.3, 'riskLevel': 'Low', 'status': 'Stable', 'isInWatchlist': 1},
      {'name': 'EnergyCo', 'ticker': 'ENG', 'price': 88.50, 'change': 5.1, 'riskLevel': 'High', 'status': 'Volatile', 'isInWatchlist': 1},
      {'name': 'SafeInvest', 'ticker': 'SFI', 'price': 120.50, 'change': 1.2, 'riskLevel': 'Low', 'status': 'Growing steadily', 'isInWatchlist': 1},
    ];

    for (final stock in sampleStocks) {
      await db.insert('stocks', stock);
    }
  }

  Future<List<Stock>> getAllStocks() async {
    final db = await database;
    final maps = await db.query('stocks');
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  Future<List<Stock>> getWatchlistStocks() async {
    final db = await database;
    final maps = await db.query('stocks', where: 'isInWatchlist = ?', whereArgs: [1]);
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  Future<List<Stock>> searchStocks(String query) async {
    final db = await database;
    final maps = await db.query(
      'stocks',
      where: 'name LIKE ? OR ticker LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => Stock.fromMap(m)).toList();
  }

  Future<void> updateStock(Stock stock) async {
    final db = await database;
    await db.update('stocks', stock.toMap(), where: 'id = ?', whereArgs: [stock.id]);
  }
}