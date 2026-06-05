import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dating_app.db');
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
    // Users table for local credentials login
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Swipes table for tracking dummy JSON profiles
    await db.execute('''
      CREATE TABLE swipes (
        id INTEGER PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        image TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        city TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  // --- Users Operations ---

  Future<int> insertUser(Map<String, dynamic> user) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final usersStr = prefs.getString('web_users');
      List<dynamic> usersList = [];
      if (usersStr != null) {
        try {
          usersList = json.decode(usersStr) as List<dynamic>;
        } catch (_) {}
      }

      // Generate ID
      int nextId = 1;
      if (usersList.isNotEmpty) {
        final ids = usersList.map((u) => (u['id'] as num?)?.toInt() ?? 0);
        nextId = (ids.isEmpty ? 0 : ids.reduce((curr, next) => curr > next ? curr : next)) + 1;
      }

      final newUser = Map<String, dynamic>.from(user);
      newUser['id'] = nextId;
      usersList.add(newUser);

      await prefs.setString('web_users', json.encode(usersList));
      return nextId;
    } else {
      final db = await instance.database;
      return await db.insert('users', user);
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final usersStr = prefs.getString('web_users');
      if (usersStr == null) return null;
      try {
        final usersList = json.decode(usersStr) as List<dynamic>;
        for (final u in usersList) {
          if (u is Map && u['email'] == email) {
            return Map<String, dynamic>.from(u);
          }
        }
        return null;
      } catch (e, stackTrace) {
        debugPrint('Error getting user by email: $e\n$stackTrace');
        return null;
      }
    } else {
      final db = await instance.database;
      final maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (maps.isNotEmpty) {
        return maps.first;
      } else {
        return null;
      }
    }
  }

  // --- Swipes Operations ---

  Future<int> insertSwipe(Map<String, dynamic> swipe) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final swipesStr = prefs.getString('web_swipes');
      List<dynamic> swipesList = [];
      if (swipesStr != null) {
        try {
          swipesList = json.decode(swipesStr) as List<dynamic>;
        } catch (_) {}
      }

      final newSwipe = Map<String, dynamic>.from(swipe);
      final index = swipesList.indexWhere((s) => s['id'] == newSwipe['id']);
      if (index != -1) {
        swipesList[index] = newSwipe;
      } else {
        swipesList.add(newSwipe);
      }

      await prefs.setString('web_swipes', json.encode(swipesList));
      return 1;
    } else {
      final db = await instance.database;
      return await db.insert(
        'swipes',
        swipe,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getSwipesByStatus(String status) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final swipesStr = prefs.getString('web_swipes');
      if (swipesStr == null) return [];
      try {
        final swipesList = json.decode(swipesStr) as List<dynamic>;
        return swipesList
            .where((s) => s['status'] == status)
            .map((s) => Map<String, dynamic>.from(s))
            .toList();
      } catch (_) {
        return [];
      }
    } else {
      final db = await instance.database;
      return await db.query(
        'swipes',
        where: 'status = ?',
        whereArgs: [status],
      );
    }
  }

  Future<List<int>> getAllSwipedIds() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final swipesStr = prefs.getString('web_swipes');
      if (swipesStr == null) return [];
      try {
        final swipesList = json.decode(swipesStr) as List<dynamic>;
        return swipesList.map((s) => (s['id'] as num).toInt()).toList();
      } catch (_) {
        return [];
      }
    } else {
      final db = await instance.database;
      final result = await db.query('swipes', columns: ['id']);
      return result.map((row) => row['id'] as int).toList();
    }
  }

  Future<void> clearSwipes() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('web_swipes');
    } else {
      final db = await instance.database;
      await db.delete('swipes');
    }
  }

  Future<void> close() async {
    if (kIsWeb) {
      // No-op on web
    } else {
      final db = await instance.database;
      db.close();
    }
  }
}
