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
import 'package:paranoia/secondary_qrscanner_publickey.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:base32/base32.dart';


class Group_Creation_Second extends StatefulWidget {
  final String pubKey;
  Group_Creation_Second(this.pubKey, {Key key}) : super (key: key);

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
    myController.text = widget.pubKey;
    return Scaffold(
        appBar: AppBar(title: Text("Create a Group")),
        body: Center(
            child: Column(
                children: <Widget>[

                  SizedBox(height: 15),
                  Text("Create a Group"),

                  TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Public Fingerprint of Primary user'
                    ),
                    controller: myController,
                  ),
                  SizedBox(height: 15),
                  RaisedButton(
                    child: Text("Scan QR Code"),
                    color: Colors.blue,
                    onPressed: (){
                      //Switch to scanner
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          SecondQRScanner("")),
                      );
                    },

                  ),
                  RaisedButton(
                    child: Text("Save Info"),
                    color: Colors.blue,
                    onPressed: (){
                      //Store in database


                      chats().then((var retVal){
                        print(retVal);
                      });

                      Navigator.popUntil(context, ModalRoute.withName('/'));

                    },

                  ),

                  QrImage(
                    data: base32.encodeString(pubFinger.toString()),
                    size: 320,
                  ),

                  Text("Public key: $pubFinger")

                ])));
  }
}
