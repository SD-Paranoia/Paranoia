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
import 'package:fluttertoast/fluttertoast.dart';

class SecondQRScanner extends StatefulWidget {
  const SecondQRScanner({
    Key key,
  }) : super(key: key);

  @override
  _SecondQRState createState() => _SecondQRState();
}

class _SecondQRState extends State<SecondQRScanner> {
  String keyVal;

  @override
  void dispose() {
    qrcontroller?.dispose();
    super.dispose();
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrPublic = "";
  QRViewController qrcontroller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x21ffffff),
        appBar: AppBar(title: Text("Scan User's Public Key")),
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
                      builder: (context) => DataCollector(text: qrPublic)));
            },
          )
        ])));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.qrcontroller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrPublic = scanData;
        Fluttertoast.showToast(
          msg: "Public key scanned, click next",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16.0
        );
//        semkey.text = qrPublic;
      });
    });
  }
}