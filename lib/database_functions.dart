import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class  ChatInfo{
  final String pubKey;
  final String name;
  final String symmetricKey;

  ChatInfo({this.pubKey, this.name, this.symmetricKey});

  Map<String, dynamic> toMap() {
    return {
      'pubKey' : pubKey,
      'name' : name,
      'symmetricKey' : symmetricKey,
    };
  }

  @override
  String toString(){
    return 'ChatInfo{pubKey: $pubKey, name: $name, symmetricKey: $symmetricKey}';
  }
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

Future<List<ChatInfo>> chats() async{
  final Database db = await openDB();

  final List<Map<String, dynamic>> maps = await db.query('chatInfo');

  return List.generate(maps.length, (i) {
    return ChatInfo(
      pubKey: maps[i]['pubKey'],
      name: maps[i]['name'],
      symmetricKey: maps[i]['symmetricKey'],
    );
  });
}

Future<void> insertChatInfo(ChatInfo chat) async{
  final Database db = await openDB();
  try {
    await db.insert(
      'chatInfo',
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }catch (e){
    throw Exception(e.toString());
  }
}

Future<int> updateChatInfo(ChatInfo chat) async{
  final Database db = await openDB();
  int status;
  try {
    status = await db.update(
      'chatInfo',
      chat.toMap(),
      //Ensure matching public key
      where: "pubKey = ?",
      //Pass the pubKey as a whereArg to prevent SQL injection
      whereArgs: [chat.pubKey],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }catch (e){
    throw Exception(e.toString());
  }
  return status;
}

Future<int> deleteChatInfo(ChatInfo chat) async{
  final Database db  = await openDB();
  int status;
  try {
    status = await db.delete(
      'chatInfo',
      where: "pubKey = ?",
      whereArgs: [chat.pubKey],
    );
  }catch (e){
    throw Exception(e.toString());
  }
  return status;

}

