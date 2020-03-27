import 'package:flutter/material.dart';
import 'package:paranoia/database_functions.dart';

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
                              MaterialPageRoute(builder: (context) => MessageView(messages: messageList,)),
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

class MessageView extends StatelessWidget{
  final List<Message> messages;

  //Require a list of messages to display
  MessageView({@required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
      ),
      //Construct the ListView of messages
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (_, int position){
          final item = messages[position];
          //Display each message on a card
          //The wasSent value determines the message appearance
          if(item.wasSent == 1){ //if message wasSent
            return Card(
              child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(item.messageText)
                ],
              ),
              ),
              color: Colors.blue,
            );
          }
          else{ //if message was received
            return Card(
              child: ListTile(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(item.messageText)
                    ],
                ),
              ),
            );
          }

          },
              )
          );
        }
  }