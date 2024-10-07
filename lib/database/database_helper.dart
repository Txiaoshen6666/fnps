import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/content_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contents.db');
    return _database!;
  }

  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'VitaDL', 'config', 'contents.db');
  }

  Future<Database> _initDB(String fileName) async {
    String path = await getDatabasePath();
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contents(
        type TEXT, -- app | dlc | theme
        titleId TEXT,
        region TEXT,
        name TEXT,
        pkgDirectLink TEXT,
        zRIF TEXT,
        contentId TEXT,
        lastModificationDate TEXT,
        originalName TEXT,
        fileSize INTEGER,
        sha256 TEXT,
        requiredFw TEXT,
        appVersion TEXT,
        PRIMARY KEY (type, titleId)
      )
    ''');
  }

  Future<void> insertContent(Content content) async {
    final db = await database;
    await db.insert(
      'contents',
      content.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertContents(List<Content> contents) async {
    final db = await database;

    final batch = db.batch();
    for (var content in contents) {
      batch.insert(
        'contents',
        content.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Content>> getContents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contents');
    return List.generate(maps.length, (i) {
      return Content.fromMap(maps[i]);
    });
  }
}
