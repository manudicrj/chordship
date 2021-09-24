import 'package:sqflite/sqflite.dart';

Future<Database> openMyDB() async {
  final Database db = await openDatabase("my_database.db", version: 2, onCreate: (Database db, int version) async {
    await db.execute('''
      CREATE TABLE song (
        id integer primary key,
        name text,
        lyrics text
      )
    ''');
  }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await db.execute('''
        ALTER TABLE songs RENAME TO song
        ''');
    }
  });
  return db;
}
