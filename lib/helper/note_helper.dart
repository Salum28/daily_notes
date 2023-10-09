import 'package:daily_notes/model/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NoteHelper {
  // Table Name
  static final String tableName = 'note';

  // Only Instance
  static final NoteHelper _noteHelper = NoteHelper._internal();

  // Database Instance
  Database? _db;

  factory NoteHelper() {
    return _noteHelper;
  }

  NoteHelper._internal();

  // Methods
  get db async {
    if(_db != null) {
      return _db;
    } else {
      _db = await inicializeDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql = 'CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR, description TEXT, date DATETIME)';
    await db.execute(sql);
  }

  inicializeDB() async {
    final dataBasePath = await getDatabasesPath();
    final dataBasePlace = join(dataBasePath, 'my_notes_db.db');
    Database db = await openDatabase(
      dataBasePlace,
      version: 1,
      onCreate: _onCreate
    );
    return db;
  }

  Future<int> saveNote(Note note) async {
    Database dataBase = await db;
    int id = await dataBase.insert(tableName, note.toMap());
    return id;
  }

  Future<List> retrieveNotes() async {
    Database dataBase = await db;
    String sql = 'SELECT * FROM $tableName ORDER BY date DESC';
    List notes = await dataBase.rawQuery(sql);
    return notes;
  }

  Future<int> updateNote(Note note) async {
    Database dataBase = await db;
    return await dataBase.update(
      tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id]
    );
  }

  Future<int> removeNote(int id) async {
    Database dataBase = await db;
    return await dataBase.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id]
    );
  }
}