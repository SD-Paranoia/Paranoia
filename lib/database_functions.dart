import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class  ChatInfo{
  final String pubKey;
  final String name;
  final String symmetricKey;
  final String serverAddress;

  ChatInfo({this.pubKey, this.name, this.symmetricKey, this.serverAddress});

  Map<String, dynamic> toMap() {
    return {
      'pubKey' : pubKey,
      'name' : name,
      'symmetricKey' : symmetricKey,
      'serverAddress' : serverAddress,
    };
  }

  @override
  String toString(){
    return 'ChatInfo{pubKey: $pubKey, name: $name, symmetricKey: $symmetricKey, serverAddress: $serverAddress}';
  }
}

class Message{
  final int messageID;
  final String pubKey;
  final int wasSent;
  final String messageText;

  Message({this.messageID, this.pubKey, this.wasSent, this.messageText});

  Map<String, dynamic> toMap() {
    return {
      'messageID' : messageID,
      'pubKey' : pubKey,
      'wasSent' : wasSent,
      'messageText' : messageText,
    };
  }
  @override
  String toString(){
    return 'Message{messageID: $messageID, pubKey: $pubKey, wasSent: $wasSent, messageText: $messageText}';
  }

}

Future<Database> openDB(String dbName) async{
  Database database;
  switch(dbName){
    case "ChatInfo":
      database = await openChatInfoDB();
      break;
    case "Message":
      database = await openMessageDB();
      break;
    default:
      database = null;
  }


  return database;

}

Future<Database> openChatInfoDB() async{
  Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'chat_info_database.db'),

    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE chatInfo(pubKey TEXT PRIMARY KEY, name TEXT, symmetricKey TEXT, serverAddress TEXT)",
      );
    },
    version:1,
  );

  return database;

}

Future<Database> openMessageDB() async{
  Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'message_database.db'),

    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE message(messageID INTEGER PRIMARY KEY, pubKey TEXT, wasSent INTEGER, messageText TEXT)",
      );
    },
    version:1,
  );

  return database;

}

Future<List<ChatInfo>> chats() async{
  final Database db = await openDB("ChatInfo");

  final List<Map<String, dynamic>> maps = await db.query('chatInfo');

  return List.generate(maps.length, (i) {
    return ChatInfo(
      pubKey: maps[i]['pubKey'],
      name: maps[i]['name'],
      symmetricKey: maps[i]['symmetricKey'],
      serverAddress: maps[i]['serverAddress'],
    );
  });
}

Future<List<Message>> messages() async{
  final Database db = await openDB("Message");

  final List<Map<String, dynamic>> maps = await db.query('message');

  return List.generate(maps.length, (i) {
    return Message(
      messageID: maps[i]['messageID'],
      pubKey: maps[i]['pubKey'],
      wasSent: maps[i]['wasSent'],
      messageText: maps[i]['messageText'],
    );
  });
}
//A function to retrieve a list of messages based on what converstation they are
// a part of
Future<List<Message>> messagesByPubKey(String pubKey) async{
  final Database db = await openDB("Message");
  //Query for the messages with the provided pubKey
  final List<Map<String, dynamic>> maps = await db.query(
    'message',
    //Ensure matching public key
    where: "pubKey = ?",
    //Pass the pubKey as a whereArg to prevent SQL injection
    whereArgs: [pubKey],
  );

  return List.generate(maps.length, (i) {
    return Message(
      messageID: maps[i]['messageID'],
      pubKey: maps[i]['pubKey'],
      wasSent: maps[i]['wasSent'],
      messageText: maps[i]['messageText'],
    );
  });
}

Future<void> insertChatInfo(ChatInfo chat) async{
  final Database db = await openDB("ChatInfo");
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

Future<void> insertMessage(Message message) async{
  final Database db = await openDB("Message");
  try {
    await db.insert(
      'message',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }catch (e){
    throw Exception(e.toString());
  }
}

Future<int> updateChatInfo(ChatInfo chat) async{
  final Database db = await openDB("ChatInfo");
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

Future<int> updateMessage(Message message) async{
  final Database db = await openDB("Message");
  int status;
  try {
    status = await db.update(
      'message',
      message.toMap(),
      //Ensure matching public key
      where: "messageID = ?",
      //Pass the pubKey as a whereArg to prevent SQL injection
      whereArgs: [message.messageID],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }catch (e){
    throw Exception(e.toString());
  }
  return status;
}

Future<int> deleteChatInfo(ChatInfo chat) async{
  final Database db  = await openDB("ChatInfo");
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

Future<int> deleteMessage(Message message) async{
  final Database db  = await openDB("Message");
  int status;
  try {
    status = await db.delete(
      'message',
      where: "messageID = ?",
      whereArgs: [message.messageID],
    );
  }catch (e){
    throw Exception(e.toString());
  }
  return status;
}