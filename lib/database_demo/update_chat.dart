
import'package:paranoia/database_functions.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paranoia/asymmetric_encryption.dart';

class UpdateChatDemo extends StatefulWidget{
  @override
  _UpdateChatState createState() => _UpdateChatState();
}

class _UpdateChatState extends State<UpdateChatDemo>{
  ChatInfo newChat, chat;
  String success;
  final myController = TextEditingController();

  ChatInfo createNewChat(String id){
    return ChatInfo(
      pubKey: id,
      fingerprint: createFingerprint(id),
      name: "User_" + id,
      symmetricKey: CryptKey().genFortuna(32),
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
        appBar: AppBar(title: Text("Update Chat in Database")),
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
                      child: Text("Update Database"),
                      onPressed: () {
                        newChat = createNewChat(myController.text);
                        updateChatInfo(newChat).then((int retVal) {
                          if(retVal > 0) {
                            setState(() {
                              chat = newChat;
                              success = "Updated symmetric key for chat: $chat";
                            });
                          }else{
                            setState(() {
                              success = "Nothing to update!";
                            });
                          }
                        }, onError: (e){
                          setState(() {
                            success = "Failed to update chat: $e";
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