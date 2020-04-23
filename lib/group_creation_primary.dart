import 'dart:convert';

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
  final String ipAddr;
  Group_Creation(this.ipAddr, {Key key}) : super (key: key);

  @override
  _Group_CreationState createState() => _Group_CreationState();
}

class _Group_CreationState extends State<Group_Creation> {

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
                        hintText: 'Public Fingerprint of Secondary user'
                    ),
                    controller: myController,
                  ),

                  RaisedButton(
                    child: Text("Save Info"),
                    color: Colors.greenAccent[400],
                    onPressed: (){
                      String finger = pubFinger.toString();
                      var hashedUUID;

                      List members = [pubFinger.toString()];

                      //Pull current user's pubkey from database
                      publicKeyAsString().then((String pubKey) {

                        //Get the private key
                        getPrivateKey().then((RSAPrivateKey privKey) {
                          //First, challenge the user
                          challengeUser(pubFinger.toString(), widget.ipAddr).then((UUID){
                            //hash the uuid
                            hashedUUID = hashUUID(UUID);

                            //now sign the challenge response
                            String signedChallenge = rsaSign(privKey, UUID);

                            //Get the public key in PEM format
                            getPublicKey().then((RSAPublicKey key2){
                              //Create the group on the server
                              createGroup(members, finger, signedChallenge, widget.ipAddr).then((n){

                              });

                            });
                          });
                        });
                        //Store in database
                        chats().then((var retVal) {
                          print(retVal);
                        });
                      });


                    },

                  ),

                  Text("Public key: $pubFinger")

                ])));
  }
}