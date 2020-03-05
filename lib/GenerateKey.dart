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
        appBar: AppBar(title: Text("Generate New Key")),
        body: Center(
            child: Column(
                children: <Widget>[

                  RaisedButton(
                    child: Text('Primary Message Creator'),
                    color: Colors.green,
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Primary()),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('Secondary Message Creator'),
                    color: Colors.blue[700],
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Secondary()),
                      );
                    },
                  )

                ])));


  }
}


