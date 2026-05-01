// ============================================================
// FILE: lib/database/auth_service.dart
// PURPOSE: Handles user Sign Up and Log In using SQLite.
//          Stores username + password in a 'users' table.
// ============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AuthService {
  // Singleton — only one instance
  static final AuthService instance = AuthService._init();
  static Database? _database;

  AuthService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('auth.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Creates the users table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL
      )
    ''');
  }

  // ── SIGN UP ────────────────────────────────────────────────
  // Returns null on success, or an error message string on failure.
  Future<String?> signUp(String username, String password) async {
    final db = await database;

    // Check if username already exists
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existing.isNotEmpty) {
      return 'Username already taken. Please choose another.';
    }

    await db.insert('users', {'username': username, 'password': password});
    return null; // success
  }

  // ── LOG IN ─────────────────────────────────────────────────
  // Returns null on success, or an error message string on failure.
  Future<String?> login(String username, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isEmpty) {
      return 'Incorrect username or password.';
    }
    return null; // success
  }
}