import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/dog.dart';

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

    final path = join(dbPath, 'dogs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE dogs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            breed TEXT,
            imageUrl TEXT,
            savedAt TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertDog(Dog dog) async {
    final db = await database;

    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Dog>> getDogs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('dogs', orderBy: 'id DESC');

    return List.generate(
      maps.length,
      (i) => Dog.fromMap(maps[i]),
    );
  }

  static Future<void> deleteDog(int id) async {
    final db = await database;

    await db.delete(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearAllDogs() async {
    final db = await database;

    await db.delete('dogs');
  }
}