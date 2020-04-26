import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class  ChatInfo{
  final String pubKey;
  final String fingerprint;
  final String name;
  final String symmetricKey;
  final String serverAddress;
  final String groupID;

  ChatInfo({this.pubKey, this.fingerprint, this.name, this.symmetricKey, this.serverAddress, this.groupID});

  Map<String, dynamic> toMap() {
    return {
      'pubKey' : pubKey,
      'fingerprint' : fingerprint,
      'name' : name,
      'symmetricKey' : symmetricKey,
      'serverAddress' : serverAddress,
      'groupID' : groupID,
    };
  }

  @override
  String toString(){
    return 'ChatInfo{pubKey: $pubKey, fingerprint: $fingerprint, name: $name, symmetricKey: $symmetricKey, serverAddress: $serverAddress, groupID: $groupID}';
  }
}

class Message{
  final int messageID;
  final String fingerprint;
  final int wasSent;
  final String messageText;

  Message({this.messageID, this.fingerprint, this.wasSent, this.messageText});

  Map<String, dynamic> toMap() {
    return {
      'messageID' : messageID,
      'pubKey' : fingerprint,
      'wasSent' : wasSent,
      'messageText' : messageText,
    };
  }
  @override
  String toString(){
    return 'Message{messageID: $messageID, fingerprint: $fingerprint, wasSent: $wasSent, messageText: $messageText}';
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
        "CREATE TABLE chatInfo(pubKey TEXT PRIMARY KEY, fingerprint TEXT, name TEXT, symmetricKey TEXT, serverAddress TEXT, groupID TEXT)",
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
        "CREATE TABLE message(messageID INTEGER PRIMARY KEY, fingerprint TEXT, wasSent INTEGER, messageText TEXT)",
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
      fingerprint: maps[i]['fingerprint'],
      name: maps[i]['name'],
      symmetricKey: maps[i]['symmetricKey'],
      serverAddress: maps[i]['serverAddress'],
      groupID: maps[i]['groupID']
    );
  });
}

Future<List<Message>> messages() async{
  final Database db = await openDB("Message");

  final List<Map<String, dynamic>> maps = await db.query('message');

  return List.generate(maps.length, (i) {
    return Message(
      messageID: maps[i]['messageID'],
      fingerprint: maps[i]['fingerprint'],
      wasSent: maps[i]['wasSent'],
      messageText: maps[i]['messageText'],
    );
  });
}
//A function to retrieve a list of messages based on what conversation they are
// a part of
Future<List<Message>> messagesByFingerprint(String fingerprint) async{
  final Database db = await openDB("Message");
  //Query for the messages with the provided pubKey
  final List<Map<String, dynamic>> maps = await db.query(
    'message',
    //Ensure matching public key
    where: "fingerprint = ?",
    //Pass the pubKey as a whereArg to prevent SQL injection
    whereArgs: [fingerprint],
  );

  return List.generate(maps.length, (i) {
    return Message(
      messageID: maps[i]['messageID'],
      fingerprint: maps[i]['fingerprint'],
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