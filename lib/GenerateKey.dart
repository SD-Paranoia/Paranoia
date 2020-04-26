import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/networking.dart';
import 'package:http/http.dart' as http;
import 'package:paranoia/file_functions.dart';
import 'package:paranoia/Primary.dart';
import 'package:paranoia/Secondary.dart';

class GenerateKey extends StatefulWidget {
  @override
  _GenerateKeyState createState() => _GenerateKeyState();
}

class _GenerateKeyState extends State<GenerateKey> {
  String keyVal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x21ffffff),
        appBar: AppBar(title: Text("Generate New Key")),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  RaisedButton(
                    child: Text('Register Primary User'),
                    color: Colors.blue,
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Primary()),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('Register Secondary User'),
                    color: Colors.blue,
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Secondary()),
                      );
                    },
                  ),

                ])));


  }
}


