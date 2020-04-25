
import 'package:paranoia/asymmetric_encryption.dart';
import'package:paranoia/database_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeleteChatDemo extends StatefulWidget{
  @override
  _DeleteChatState createState() => _DeleteChatState();
}

class _DeleteChatState extends State<DeleteChatDemo>{
  ChatInfo newChat, chat;
  String success;
  final myController = TextEditingController();

  ChatInfo createNewChat(String id){
    return ChatInfo(
      pubKey: id,
      fingerprint: createFingerprint(id),
      name: "User_" + id,
      symmetricKey: null,
      serverAddress: "http://127.0.0.1:8080",
      groupID: "group_id",
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
        appBar: AppBar(title: Text("Delete Chat from Database")),
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
                      child: Text("Delete Chat"),
                      onPressed: () {
                        newChat = createNewChat(myController.text);
                        deleteChatInfo(newChat).then((int retVal) {
                          if(retVal > 0) {
                            setState(() {
                              chat = newChat;
                              success = "Deleted Chat: $chat";
                            });
                          }else{
                            setState(() {
                              success = "Nothing to delete!";
                            });
                          }
                        }, onError: (e){
                          setState(() {
                            success = "Failed to delete chat: $e";
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