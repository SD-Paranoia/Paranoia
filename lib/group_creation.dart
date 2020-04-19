import 'package:flutter/material.dart';
import 'package:paranoia/asymmetric_encryption.dart';
import 'package:paranoia/database_functions.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/file_functions.dart';
import 'package:http/http.dart' as http;
import 'package:paranoia/database_demo.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'local_store.dart';
import 'package:paranoia/networking.dart';
import 'package:paranoia/CreateServer.dart';
import 'package:paranoia/GenerateKey.dart';


class Group_Creation extends StatefulWidget {

  @override
  _Group_CreationState createState() => _Group_CreationState();
}

class _Group_CreationState extends State<Group_Creation> {
  String keyVal;

  final myController = TextEditingController();
  final name = TextEditingController();
  final pubkey = TextEditingController();

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void dispose1(){
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Create a Group")),
        body: Center(
            child: Column(
                children: <Widget>[

                  Text("Idk what this is"),

                  RaisedButton(
                    child: Text("Save Info"),
                    color: Colors.greenAccent[400],
                    onPressed: (){
                      //TODO -- store in database
                    },
                  )

                ])));
  }
}