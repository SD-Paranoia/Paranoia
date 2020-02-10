import 'package:flutter/material.dart';
import 'package:paranoia/database_demo.dart';
import 'local_store.dart';


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
              child: Text('My Key'),
              color: Colors.blue,
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyKey()),
                );
              },
            ),
            RaisedButton(
              child: Text('Chats'),
              color: Colors.blue,
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Chats()));
              },
            ),
            RaisedButton(
              child: Text('Local Store Demo'),
              color: Colors.blue,
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LocalStorage()));
              },
            ),
            RaisedButton(
              child: Text('Database Demo'),
              color: Colors.blue,
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DatabaseDemo()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyKey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Key'),
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
        title: Text('Chats'),
      ),
      body: Center(

      ),
    );
  }
}