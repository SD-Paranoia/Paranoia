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

class Secondary extends StatefulWidget {

  const Secondary({
    Key key,
  }) : super(key: key);

  @override
  _SecondaryState createState() => _SecondaryState();
}

class _SecondaryState extends State<Secondary> {
  String keyVal;

  final semkey = TextEditingController();

  @override
  void dispose(){
    qrcontroller?.dispose();
    semkey.dispose();
    super.dispose();
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController qrcontroller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Secondary Message Creator")),
        body: Center(
            child: Column(
                children: <Widget>[
                  Expanded(
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderColor: Colors.red,
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: 300,
                      ),
                    ),
                    
                    flex: 4,
                  ),
                  RaisedButton(
                    child: Text("Flip Camera"),
                    color: Colors.greenAccent[400],
                    onPressed: (){
                      qrcontroller.flipCamera();
                    },
                  ),
                  RaisedButton(
                    child: Text("Next"),
                    color: Colors.greenAccent[400],
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DataCollector(text: qrText)));
                    },
                  )

                ])));
  }
  void _onQRViewCreated(QRViewController controller) {
    this.qrcontroller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        semkey.text = qrText;
      });
    });
  }
}

class DataCollector extends StatelessWidget{

  final String text;
  final myController = TextEditingController();
  final name = TextEditingController();

  DataCollector({@required this.text});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Secondary User Data Collection")),
      body: Center(
        child: Column(
          children: <Widget>[

            Text("Enter Server Information"),
            TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'URI input (IP:PORT)'
              ),
              controller: myController,
            ),
            TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Name of User (optional)'
              ),
              controller: name,
            ),
            RaisedButton(
              child: Text("Save Info"),
              color: Colors.greenAccent[400],
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
                  ChatInfo chat = ChatInfo (pubKey: pubKey, name: name.text, symmetricKey: text, serverAddress: myController.text);
                  insertChatInfo(chat);
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Group_Creation_Second(myController.text)),
                );
              },

            )
          ],
        ),
      ),
    );
  }
}