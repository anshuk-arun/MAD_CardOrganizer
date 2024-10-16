import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "CardOrganizer.db";
  static const _databaseVersion = 1;

  static const tableFolders = 'folders';
  static const tableCards = 'cards';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  late Database database;
  

  Future<void> init() async{
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    database = await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFolders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER,
        FOREIGN KEY (folder_id) REFERENCES folders (id)
      )
    ''');

    // Prepopulate folders and cards
    await db.insert(tableFolders, {'folder_name': 'Hearts'});
    await db.insert(tableFolders, {'folder_name': 'Spades'});
    await db.insert(tableFolders, {'folder_name': 'Diamonds'});
    await db.insert(tableFolders, {'folder_name': 'Clubs'});

    // Add sample cards
    await db.insert(tableCards, {'name': 'Ace', 'suit': 'Hearts', 'image_url': 'url', 'folder_id': 1});
    // Add more cards here...
  }

  // CRUD Methods
  Future<List<Map<String, dynamic>>> fetchFolders() async {
    Database db = await instance.database;
    return await db.query(tableFolders);
  }

  Future<List<Map<String, dynamic>>> fetchCards(int folderId) async {
    Database db = await instance.database;
    return await db.query(tableCards, where: 'folder_id = ?', whereArgs: [folderId]);
  }

  Future<void> insertCard(Map<String, dynamic> card) async {
    Database db = await instance.database;
    await db.insert(tableCards, card);
  }

  Future<void> deleteCard(int id) async {
    Database db = await instance.database;
    await db.delete(tableCards, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCard(Map<String, dynamic> card) async {
    Database db = await instance.database;
    await db.update(tableCards, card, where: 'id = ?', whereArgs: [card['id']]);
  }
}