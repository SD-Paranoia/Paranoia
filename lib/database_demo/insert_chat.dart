
import 'package:paranoia/database_functions.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class InsertChatDemo extends StatefulWidget{
  @override
  _InsertChatState createState() => _InsertChatState();
}

class _InsertChatState extends State<InsertChatDemo>{
  ChatInfo newChat, chat;
  String success;
  final myController = TextEditingController();
  Uri myUri = Uri.parse("http://127.0.0.1:8080");

  ChatInfo createNewChat(String id){
    return ChatInfo(
      pubKey: id,
      name: "User_" + id,
      symmetricKey: CryptKey().genFortuna(32),
      serverAddress: "http://127.0.0.1:8080",
    );
  }

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
                    hintText: 'Enter a unique ID (A Public Key perhaps)'
                ),
                controller: myController,
              ),
              RaisedButton(
                  child: Text("Insert Into Database"),
                  onPressed: () {
                    newChat = createNewChat(myController.text);
                    insertChatInfo(newChat).then((void retVal) {
                        setState(() {
                          chat = newChat;
                          success = "Added new chat: $chat";
                        });
                    }, onError: (e){
                      setState(() {
                        success = "Failed to add chat: $e";
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