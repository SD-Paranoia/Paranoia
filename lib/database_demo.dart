import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paranoia/database_demo/database_demo_lib.dart';
import 'package:sqflite/sqflite.dart';
import 'database_functions.dart';

class DatabaseDemo extends StatefulWidget{
  @override
  _DatabaseDemoState createState() => _DatabaseDemoState();
}

class _DatabaseDemoState extends State<DatabaseDemo>{
  Database db;
  bool openCheck;
  String userInfo;
  int counter;
  List<ChatInfo> chatList;

  @override
  void initState(){
    super.initState();
    openDB().then((Database database){
      db = database;
    });
    chats().then((List<ChatInfo> chatDB){
      setState(() {
        chatList = chatDB;
        counter = chatList.length;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Database Demo Widget")),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Database: $chatList"),

            RaisedButton(
              child: Text("Refresh Database View"),
              onPressed: (){
                chats().then((List<ChatInfo> chatDB){
                  setState(() {
                    chatList = chatDB;
                  });
                });
              },
            ),

            RaisedButton(
              child: Text("Insert Into Database"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InsertChatDemo()),
                );
              }),

            RaisedButton(
                child: Text("Update Database"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UpdateChatDemo()),
                  );
                }),

            RaisedButton(
                child: Text("Delete From Database"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeleteChatDemo()),
                  );
                }),

          ],
        )
      ),
    );
  }}