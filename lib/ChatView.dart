import 'package:flutter/material.dart';
import 'package:paranoia/asymmetric_encryption.dart';
import 'package:paranoia/database_functions.dart';
import 'package:paranoia/database_functions.dart' as prefix0;
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/networking.dart';
import 'package:steel_crypt/PointyCastleN/export.dart';

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
                          messagesByPubKey(item.pubKey).then((List<Message> messageList){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MessageView(messages: messageList, chatInfo: item)),
                            );
                          });
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
  final List<Message> messages;
  final ChatInfo chatInfo;
  //Require a list of messages to display
  MessageView({@required this.messages, @required this.chatInfo});

  @override
  _MessageViewState createState() => new _MessageViewState();
}


class _MessageViewState extends State<MessageView>{

  final messageTextController = TextEditingController();
  int messageCount;
  //Needed to cleanup the text editing controller and free
  // its resources
  @override
  void dispose(){
    messageTextController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    messages().then((List<Message> messagesList){
      setState(() {
        messageCount = messagesList.length;
      });
    });
  }

  void sendMessage() async{
    final messageID = messageCount + 1;
    final privateKey = await getPrivateKey();
    //Encrypt the message
    String messageText = encryptMsg(widget.chatInfo.symmetricKey, messageTextController.text, privateKey);
    //Create a new message
    Message newMessage = new Message(
        messageID: messageID,
        messageText: messageText,
        pubKey: widget.chatInfo.pubKey,
        wasSent: 1,
    );
    //Add the new message to the database
    insertMessage(newMessage);

    messageTextController.clear();
    setState(() {
      widget.messages.add(newMessage);
      messageCount = messageID;
    });

    //TODO Send message over network for other user


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
                itemCount: widget.messages.length,
                itemBuilder: (_, int position){
                  final item = widget.messages[position];
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