import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class  ChatInfo{
  final String pubKey;
  final String name;
  final String symmetricKey;

  ChatInfo({this.pubKey, this.name, this.symmetricKey});
}

Future<Database> openDB() async{
  Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'chat_info_database.db'),

    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE chatInfo(pubKey TEXT PRIMARY KEY, name TEXT, symmetricKey TEXT)",
      );
    },
    version:1,
  );

  return database;

}
