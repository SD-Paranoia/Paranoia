import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paranoia/asymmetric_encryption.dart';
import 'package:paranoia/database_functions.dart';
import 'package:paranoia/demo.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/file_functions.dart';
import 'package:http/http.dart' as http;
import 'package:paranoia/database_demo.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'local_store.dart';
import 'package:paranoia/networking.dart';
import 'package:paranoia/CreateServer.dart';
import 'package:paranoia/GenerateKey.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
//import 'package:qrscan/qrscan.dart' as scanner;
import 'package:base32/base32.dart';


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
    qrcontroller?.dispose();
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

  String scannedKey = "default";

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController qrcontroller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x21ffffff),
        appBar: AppBar(title: Text("Create a Group")),
        body: Center(
            child: Column(
                children: <Widget>[
                  SizedBox(height: 15),

                  Text("Create a Group",
                    style: TextStyle(color: Color(0xffffffff), fontSize: 15),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                  ),
                  RaisedButton(
                    child: Text("Flip Camera"),
                    color: Colors.blue,
                    onPressed: () {
                      qrcontroller.flipCamera();
                    },
                  ),

                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0x10f0f0f0),
                        hintText: 'Public Fingerprint of Secondary user'
                    ),
                    controller: myController,
                  ),
                  SizedBox(height: 15),

                  Text(scannedKey),

                  RaisedButton(
                    child: Text("Save Info"),
                    color: Colors.blue,
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

                      print(finger);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PubkeyQR(pub: finger,)),);
                      },

                  ),

                  /*Text("Public key: \n$pubFinger",
                    style: TextStyle(color: Color(0xffffffff), fontSize: 15),
                  ),
                  QrImage(
                    data: base32.encodeString(pubFinger.toString()),
                    size: 320,
                  ),
                  Text("Public key: $pubFinger")*/

                ])));
  }
  void _onQRViewCreated(QRViewController controller) {
    this.qrcontroller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = base32.decodeAsHexString(scanData);
        myController.text = qrText;
      });
    });
  }
/*
  Future scanQR() async {
    try {
      String key;
      key = await scanner.scan();
      setState(() => this.scannedKey = key);
    } catch (e) {
      setState(() {
        this.scannedKey = 'An error $e has occured';
      });
    }
  }
*/
}

class PubkeyQR extends StatelessWidget{

  final String pub;

  PubkeyQR({@required this.pub});

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: Text('My Public Key'),
        ),
        body:
        Center(
          child: Column(
              children: <Widget>[
                QrImage(
                  data: base32.encodeString(pub), size: 320,),
                RaisedButton(
                  child: Text('Home'),
                  onPressed: (){
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                )
              ]

          ),
        )

    );
  }
}