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
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:base32/base32.dart';
import 'dart:convert';

class Secondary extends StatefulWidget {
  const Secondary({
    Key key,
  }) : super(key: key);

  @override
  _SecondaryState createState() => _SecondaryState();
}

class _SecondaryState extends State<Secondary> {
  String keyVal;

  @override
  void dispose() {
    qrcontroller?.dispose();
    super.dispose();
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrSym = "";
  QRViewController qrcontroller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x21ffffff),
        appBar: AppBar(title: Text("Scan Symmetric QR Code")),
        body: Center(
            child: Column(children: <Widget>[
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
            flex: 4,
          ),
          RaisedButton(
            child: Text("Flip Camera"),
            color: Colors.blue,
            onPressed: () {
              qrcontroller.flipCamera();
            },
          ),
          RaisedButton(
            child: Text("Next"),
            color: Colors.blue,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DataCollector(text: qrSym)));
            },
          )
        ])));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.qrcontroller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrSym =  base32.decodeAsHexString(scanData);
        Fluttertoast.showToast(
          msg: "Symmetric key scanned, click next",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16.0
        );
//        semkey.text = qrSym;
      });
    });
  }
}

class DataCollector extends StatelessWidget {
  final String text;
  final myController = TextEditingController();
  final name = TextEditingController();
  final semkey = TextEditingController();

  DataCollector({@required this.text});

  @override
  Widget build(BuildContext context) {
    semkey.text = text;
    return Scaffold(
      backgroundColor: Color(0x21ffffff),
      appBar: AppBar(title: Text("Secondary User Data Collection")),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            Text(
              "Enter Server Information",
              style: TextStyle(color: Color(0xffffffff), fontSize: 15),
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0x10f0f0f0),
                  hintText: 'URI input (IP:PORT)'),
              controller: myController,
            ),
            SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0x10f0f0f0),
                  hintText: 'Name of User (optional)'),
              controller: name,
            ),
            SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0x10f0f0f0),
                  hintText: 'Symmetric key for encryption (stubbed for TODO)'),
              controller: semkey,
            ),
            SizedBox(height: 15),
            RaisedButton(
              child: Text("Save Info"),
              color: Colors.blue,
              onPressed: () {
                semkey.text = text;
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
                  if(name.text == ""){
                    name.text = pubKey.toString().substring(100,108);
                  }
                  ChatInfo chat = ChatInfo(
                      pubKey: pubKey,
                      fingerprint: createFingerprint(pubKey),
                      name: name.text,
                      symmetricKey: text,
                      serverAddress: myController.text);
                  insertChatInfo(chat);
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Group_Creation_Second("")),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
