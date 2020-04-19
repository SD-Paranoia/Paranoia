import 'package:flutter/material.dart';
import 'package:paranoia/ChatView.dart';
import 'package:paranoia/database_demo.dart';
import 'local_store.dart';
import 'package:paranoia/NetworkDemo.dart';
import 'package:paranoia/CreateServer.dart';
import 'package:paranoia/Primary.dart';


void main(){
  runApp(MaterialApp(
    title: 'Paranoia',
    home: ParanoiaHome(),
  ));
}

class ParanoiaHome extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        leading: IconButton(
//          icon: Icon(Icons.menu),
//          tooltip: 'Navigation menu',
//          onPressed: null,
//        ),
        title: Text('Paranoia'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Register New User'),
              color: Colors.blue,
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Primary()),
                );
              },
            ),

            RaisedButton(
                child: Text('Chats'),
                color: Colors.blue,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatView()));
                }
            )

          ],
        ),
      ),
    );
  }
}

class ViewKey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Personal Key'),
      ),
      body: Center(
        child: Image(
            image: AssetImage("images/football-png-11.png")
        ),
      ),
    );
  }
}

class AddAKey extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Key'),
      ),
      body: Center(
      ),
    );
  }
}

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Refresh'),
              color: Colors.green,
              onPressed: (){
                //TODO -- Resync with server
              }
            )
          ]
        )
      ),
    );
  }
}