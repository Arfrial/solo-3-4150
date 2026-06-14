import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/fish.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, 'fish.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fish(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            imageUrl TEXT,
            savedAt TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertFish(Fish fish) async {
    final db = await database;

    await db.insert(
      'fish',
      fish.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Fish>> getFish() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('fish', orderBy: 'id DESC');

    return List.generate(
      maps.length,
      (i) => Fish.fromMap(maps[i]),
    );
  }

  static Future<void> deleteFish(int id) async {
    final db = await database;

    await db.delete(
      'fish',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearAllFish() async {
    final db = await database;

    await db.delete('fish');
  }
}