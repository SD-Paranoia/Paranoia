import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paranoia/database_demo/database_demo_lib.dart';
import 'package:sqflite/sqflite.dart';
import 'database_functions.dart';


Message createNewMessage(int count, String id, int wasSent, String text){
  return Message(
    messageID: count,
    fingerprint: id,
    wasSent: wasSent,
    messageText: text,
  );
}

void main(){
  runApp(MaterialApp(
    title: 'Paranoia',
    home: DatabaseDemoMessage(),
  ));
}

class DatabaseDemoMessage extends StatefulWidget{
  @override
  _DatabaseDemoMessageState createState() => _DatabaseDemoMessageState();
}

class _DatabaseDemoMessageState extends State<DatabaseDemoMessage>{
  Database db;
  List<Message> messageList;
  @override
  void initState(){
    super.initState();
    openDB("Message").then((Database database){
      db = database;
    });
    messages().then((List<Message> messageDB){
      setState(() {
        messageList = messageDB;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Message Database Demo Widget")),
      body: Center(
          child: Column(
            children: <Widget>[
              Text("Database: $messageList"),

              RaisedButton(
                child: Text("Refresh Database View"),
                onPressed: (){
                  messages().then((List<Message> messageDB){
                    setState(() {
                      messageList = messageDB;
                    });
                  });
                },
              ),

              RaisedButton(
                  child: Text("Insert Into Database"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InsertMessageDemo()),
                    );
                  }),

              RaisedButton(
                  child: Text("Update Database"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpdateMessageDemo()),
                    );
                  }),

              RaisedButton(
                  child: Text("Delete From Database"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeleteMessageDemo()),
                    );
                  }),

            ],
          )
      ),
    );
  }}


class InsertMessageDemo extends StatefulWidget{
  @override
  _InsertMessageState createState() => _InsertMessageState();
}

class _InsertMessageState extends State<InsertMessageDemo>{
  Message newMessage, message;
  String success;
  final myController = TextEditingController();


  //Needed to cleanup the text editing controller and free
  // its resources
  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    success = '';
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text("Insert Into Database")),
        body: Center(
            child: Column(
                children: <Widget>[
                  // The text entry field
                  TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter a unique ID (A messageID perhaps)'
                    ),
                    controller: myController,
                  ),
                  RaisedButton(
                      child: Text("Insert Into Database"),
                      onPressed: () {
                        newMessage = createNewMessage(int.parse(myController.text), "Jordan", 1, "message");
                        insertMessage(newMessage).then((void retVal) {
                          setState(() {
                            message = newMessage;
                            success = "Added new message: $message";
                          });
                        }, onError: (e){
                          setState(() {
                            success = "Failed to add message: $e";
                          });
                        });
                      }),
                  Text(success)
                ]
            )
        )
    );
  }
}

class UpdateMessageDemo extends StatefulWidget{
  @override
  _UpdateMessageState createState() => _UpdateMessageState();
}

class _UpdateMessageState extends State<UpdateMessageDemo>{
  Message newMessage, message;
  String success;
  final myController = TextEditingController();


  //Needed to cleanup the text editing controller and free
  // its resources
  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    success = '';
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text("Update Message in Database")),
        body: Center(
            child: Column(
                children: <Widget>[
                  // The text entry field
                  TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter a unique ID (A messageID perhaps)'
                    ),
                    controller: myController,
                  ),
                  RaisedButton(
                      child: Text("Update Database"),
                      onPressed: () {
                        newMessage = createNewMessage(int.parse(myController.text), "Jordan", 0, "updated message");
                        updateMessage(newMessage).then((int retVal) {
                          if(retVal > 0) {
                            setState(() {
                              message = newMessage;
                              success = "Updated symmetric key for message: $message";
                            });
                          }else{
                            setState(() {
                              success = "Nothing to update!";
                            });
                          }
                        }, onError: (e){
                          setState(() {
                            success = "Failed to update message: $e";
                          });
                        });
                      }),
                  Text(success)
                ]
            )
        )
    );
  }
}

class DeleteMessageDemo extends StatefulWidget{
  @override
  _DeleteMessageState createState() => _DeleteMessageState();
}

class _DeleteMessageState extends State<DeleteMessageDemo>{
  Message newMessage, message;
  String success;
  final myController = TextEditingController();

  //Needed to cleanup the text editing controller and free
  // its resources
  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    success = '';
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text("Delete Message from Database")),
        body: Center(
            child: Column(
                children: <Widget>[
                  // The text entry field
                  TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter a unique ID (A messageID perhaps)'
                    ),
                    controller: myController,
                  ),
                  RaisedButton(
                      child: Text("Delete Message"),
                      onPressed: () {
                        newMessage = createNewMessage(int.parse(myController.text), "Jordan", 0, " ");
                        deleteMessage(newMessage).then((int retVal) {
                          if(retVal > 0) {
                            setState(() {
                              message = newMessage;
                              success = "Deleted Message: $message";
                            });
                          }else{
                            setState(() {
                              success = "Nothing to delete!";
                            });
                          }
                        }, onError: (e){
                          setState(() {
                            success = "Failed to delete message: $e";
                          });
                        });
                      }),
                  Text(success)
                ]
            )
        )
    );
  }
}