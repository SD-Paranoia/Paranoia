import 'package:flutter/material.dart';
import 'package:paranoia/asymmetric_encryption.dart';
import 'package:paranoia/database_functions.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/file_functions.dart';
import 'package:http/http.dart' as http;
import 'package:paranoia/database_demo.dart';
import 'package:paranoia/group_creation_primary.dart';
import 'package:paranoia/group_creation_secondary.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'local_store.dart';
import 'package:paranoia/networking.dart';
import 'package:paranoia/CreateServer.dart';
import 'package:paranoia/GenerateKey.dart';

class Secondary extends StatefulWidget {

  @override
  _SecondaryState createState() => _SecondaryState();
}

class _SecondaryState extends State<Secondary> {
  String keyVal;

  final myController = TextEditingController();
  final name = TextEditingController();
  final semkey = TextEditingController();

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
  void dispose2(){
    semkey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x21ffffff),
        appBar: AppBar(title: Text("Secondary Message Creator")),
        body: Center(
            child: Column(
                children: <Widget>[
                  SizedBox(height: 15),

                  Text("Enter Server Information",
                    style: TextStyle(color: Color(0xffffffff), fontSize: 15),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0x10f0f0f0),
                        hintText: 'URI input (IP:PORT)'
                    ),
                    controller: myController,
                  ),
                  SizedBox(height: 5),
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0x10f0f0f0),
                        hintText: 'Name of User (optional)'
                    ),
                    controller: name,
                  ),
                  SizedBox(height: 5),
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0x10f0f0f0),
                        hintText: 'Symmetric key for encryption (stubbed for TODO)'
                    ),
                    controller: semkey,
                  ),
                  SizedBox(height: 15),
                  RaisedButton(
                    child: Text("Save Info"),
                    color: Colors.blue,
                    onPressed: (){
                      //TODO -- register user via network
                      String pubKey = "";
                      //Generate new asymmetric key and store in database
                      generatePublicPrivateKeypair();

                      //Pull current user's pubkey from database
                      publicKeyAsString().then((String retVal) {
                        //Get the public key
                        pubKey = retVal;
                        //Get the private key
                        getPrivateKey().then((RSAPrivateKey privKey) {
                          //Sign the public key with the private
                          String signedPublic = rsaSign(privKey, pubKey);
                          //Get the public key
                          getPublicKey().then((RSAPublicKey key2) {
                            //Now after signed, send it to server to register user
                            registerUser(pubKey, signedPublic, myController.text);
                          });
                        });

                        //Store chat data into database
                        ChatInfo chat = ChatInfo (pubKey: pubKey, name: name.text, symmetricKey: semkey.text, serverAddress: myController.text);
                        insertChatInfo(chat);
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Group_Creation_Second(myController.text)),
                      );
                    },

                  )

                ])));
  }
}