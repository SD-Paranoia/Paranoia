import 'package:flutter/material.dart';
import 'package:paranoia/ChatView.dart';
import 'package:paranoia/asymmetric_encryption.dart';
import 'package:paranoia/database_demo.dart';
import 'local_store.dart';
import 'package:paranoia/NetworkDemo.dart';
import 'package:paranoia/CreateServer.dart';
import 'package:paranoia/GenerateKey.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MaterialApp(
    title: 'Paranoia',
    home: ParanoiaHome(),
  ));
}

class ParanoiaHome extends StatelessWidget {
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Generate My Keypair'),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0),
              ),
              onPressed: (){
                Fluttertoast.showToast(
                    msg: "Generating key. This may take a minute.",
                    backgroundColor: Colors.lightGreenAccent,
                    textColor: Colors.black,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    fontSize: 16.0
                );
                generatePublicPrivateKeypair();
                Fluttertoast.showToast(
                    msg: "Key Generated!",
                    backgroundColor: Colors.lightGreenAccent,
                    textColor: Colors.black,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    fontSize: 16.0
                );
                //Fluttertoast.cancel();

              },
            ),
            SizedBox(height: 15),
            RaisedButton(
              child: Text('Register New User'),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GenerateKey()),
                );
              },
            ),
            SizedBox(height: 15),
            RaisedButton(
                child: Text('Chats'),
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatView()));
                })
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
        child: Image(image: AssetImage("images/football-png-11.png")),
      ),
    );
  }
}

class AddAKey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Key'),
      ),
      body: Center(),
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
          child: Column(children: <Widget>[
        RaisedButton(
            child: Text('Refresh'),
            color: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            onPressed: () {
              //TODO -- Resync with server
            })
      ])),
    );
  }
}
