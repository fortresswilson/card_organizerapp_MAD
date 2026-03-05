import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static const _databaseName = "card_organizer.db";
  static const _databaseVersion = 1;

  static const foldersTable = "folders";
  static const cardsTable = "cards";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: _onCreate,
    );
  }

  Future<void> init() async {
    await database;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE folders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      folder_name TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE cards (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      card_name TEXT NOT NULL,
      suit TEXT NOT NULL,
      image_url TEXT NOT NULL,
      folder_id INTEGER NOT NULL,
      FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
    )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    int heartsId = await db.insert("folders", {
      "folder_name": "Hearts",
      "timestamp": now,
    });

    int spadesId = await db.insert("folders", {
      "folder_name": "Spades",
      "timestamp": now,
    });

    const ranks = [
      "A","2","3","4","5","6","7","8","9","10","J","Q","K"
    ];

    Batch batch = db.batch();

    for (var r in ranks) {
      batch.insert("cards", {
        "card_name": r,
        "suit": "Hearts",
        "image_url": "assets/cards/hearts.jpg",
        "folder_id": heartsId
      });

      batch.insert("cards", {
        "card_name": r,
        "suit": "Spades",
        "image_url": "assets/cards/spades.jpg",
        "folder_id": spadesId
      });
    }

    await batch.commit(noResult: true);
  }
}