import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/networking.dart';
import 'package:http/http.dart' as http;
import 'package:paranoia/file_functions.dart';


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
                    child: Text('Generate Symmetric Key'),
                    color: Colors.green,
                    onPressed: (){
                      generateSymmetricKey();
                      readFromFile('symmetricKey.txt').then((String value) {
                        setState(() {
                          keyVal = value;
                        });
                      });
                    },
                  ),
                  Text(
                      'New generated key: \n$keyVal\n'
                  ),
                ])));


  }
}
