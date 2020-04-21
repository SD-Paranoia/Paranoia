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


class Group_Creation_Second extends StatefulWidget {
  final String ipAddr;
  Group_Creation_Second(this.ipAddr, {Key key}) : super (key: key);

  @override
  _Group_CreationSState createState() => _Group_CreationSState();
}

class _Group_CreationSState extends State<Group_Creation_Second> {

  final myController = TextEditingController();
  var pubFinger;
  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    getPublicFingerprint().then((var fingerPrint){
      setState(() {
        pubFinger = fingerPrint;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Create a Group")),
        body: Center(
            child: Column(
                children: <Widget>[

                  Text("Create a Group"),

                  TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Public Fingerprint of Primary user'
                    ),
                    controller: myController,
                  ),

                  RaisedButton(
                    child: Text("Save Info"),
                    color: Colors.greenAccent[400],
                    onPressed: (){
                      //Store in database


                      chats().then((var retVal){
                        print(retVal);
                      });

                    },

                  ),

                  Text("Public key: $pubFinger")

                ])));
  }
}