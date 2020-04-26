import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paranoia/asymmetric_encryption.dart';
import 'package:paranoia/database_functions.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/networking.dart';
import 'package:http/http.dart' as http;

class ChatView extends StatefulWidget{

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x21ffffff),
        appBar: AppBar(
          title: Text("Chats"),
    ),
    //Build the list of Chats based on the chats in the Database
    body: FutureBuilder<List<ChatInfo>>(
      future: chats(),
      builder: (context, snapshot){
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, int position){
                    final item = snapshot.data[position];
                    return Card(
                        color: Colors.blue,
                      child: ListTile(
                        title: Text(
                          item.name
                        ),
                        onTap: (){
                          //If we tap on a chat, it will take us to the messages
                          // associated with that chat
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MessageView(chatInfo: item)),
                          );
                        },
                      )
                    );
                  },
          )
              : Center(
            child: CircularProgressIndicator(),
          );
      }
    )
    );
}
}

class MessageView extends StatefulWidget{
  final ChatInfo chatInfo;
  //Require a list of messages to display
  MessageView({@required this.chatInfo});

  @override
  _MessageViewState createState() => new _MessageViewState();
}


class _MessageViewState extends State<MessageView>{

  final messageTextController = TextEditingController();
  List<Message> messageList = new List<Message>();
  int messageCount;
  var privateKey;
  var fingerPrint;
  //Needed to cleanup the text editing controller and free
  // its resources
  @override
  void dispose(){
    messageTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getPublicFingerprint().then((var fing){
      setState(() {
        fingerPrint = fing;
      });
      getPrivateKey().then((var key){
        setState(() {
          privateKey = key;
        });
        messages().then((List<Message> allMessages){
          setState(() {
            messageCount = allMessages.length;
          });
          getMessages().then((void retVal){
            messagesByFingerprint(fingerPrint.toString()).then((List<Message> messages){
              setState(() {
                messageList = messages;
              });
            });//messagesByFingerprint
          });//getMessages()
        });//messages()
      });//getPrivateKey()
    });//getPublicFingerprint()
  }

  Future<void> getMessages()async{
    //Challenge the user to get the UUID
    String uuid = await challengeUser(fingerPrint.toString(), widget.chatInfo.serverAddress);
    //Create the signed challenge
    String challenge = rsaSign(privateKey, uuid);
    getMsg(fingerPrint.toString(), challenge, widget.chatInfo.serverAddress)
    .then((http.Response response){
      if(response.statusCode == 200){
        Map<String, dynamic> jsonObj = jsonDecode(response.body);
        for(var item in jsonObj["Msgs"]){
          Message newMessage = Message(
            messageID: ++messageCount,
            fingerprint: item["From"],
            wasSent: 0,
            messageText: item["Content"]
          );
          insertMessage(newMessage);
        }
      }
      else{
        //Present an alert to retry send
        showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("Failed to Load Messages"),
                content: Text("Please try again."),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Close"),
                    onPressed:(){
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
        );
      }
    });
  }


  void sendMessage() async{
    final messageID = messageCount + 1;
    //Encrypt the message
    String messageText = encryptMsg(widget.chatInfo.symmetricKey, messageTextController.text, privateKey);
    //Create a new message
    Message newMessage = new Message(
        messageID: messageID,
        messageText: messageText,
        fingerprint: widget.chatInfo.fingerprint,
        wasSent: 1,
    );

    //Challenge the user to get the UUID
    String uuid = await challengeUser(fingerPrint.toString(), widget.chatInfo.serverAddress);
    //Create the signed challenge
    String challenge = rsaSign(privateKey, uuid);
    //Send the message
    sendMsg(messageText, fingerPrint.toString(), challenge, widget.chatInfo.groupID, widget.chatInfo.serverAddress)
    .then((http.Response response){
      if(response.statusCode == 200){
        //Add the new message to the database
        insertMessage(newMessage);

        messageTextController.clear();
        setState(() {
          messageList.add(newMessage);
          messageCount = messageID;
        });
      }
      else{
        //Present an alert to retry send
        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("Message Failed to Send!"),
              content: Text("Please try again."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Close"),
                  onPressed:(){
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
        );
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x21ffffff),
      appBar: AppBar(
        title: Text(widget.chatInfo.name),
      ),
      //Construct the ListView of messages
      body: Column(
        children: <Widget>[
          Flexible(
              child: ListView.builder(
                itemCount: messageList.length,
                itemBuilder: (_, int position){
                  final item = messageList[position];
                  //Display each message on a card
                  //The wasSent value determines the message appearance
                  if(item.wasSent == 1){ //if message was sent
                    return Card(
                      child: Text(
                        decryptMsg(
                          widget.chatInfo.symmetricKey,
                          item.messageText,
                          widget.chatInfo.pubKey
                        )
                      ),
                      color: Colors.blue,

                    );
                  }
                  else{ //if message was received
                    return Card(
                      color: Colors.tealAccent,
                      child:Text(
                          decryptMsg(
                              widget.chatInfo.symmetricKey,
                              item.messageText,
                              widget.chatInfo.pubKey
                          )
                      )
                    );
                  }
                },
              ),
          ),
          // The text entry field
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0x10f0f0f0),
                hintText: 'Write Something...'
            ),
            controller: messageTextController,
          ),
          RaisedButton(
            child: Text("Send"),
            onPressed: sendMessage,
          )
        ],
      )
          );
        }
  }