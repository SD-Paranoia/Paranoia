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
  final ChatInfo chat;
  final String pubQRKey;
  Group_Creation_Second(this.chat, this.pubQRKey, {Key key}) : super (key: key);

  @override
  _Group_CreationSState createState() => _Group_CreationSState();
}

class _Group_CreationSState extends State<Group_Creation_Second> {

  final myController = TextEditingController();
  final groupIDField = TextEditingController();
  var pubFinger;
  RSAPublicKey pubKeyInit;
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

    getPublicKey().then((RSAPublicKey pubKey){
      setState(() {
        pubKeyInit = pubKey;
      });
    });

    widget.chat.name;
    widget.chat.symmetricKey;
    widget.chat.serverAddress;
    groupIDField.text;

  }
  

  @override
  Widget build(BuildContext context) {
    myController.text = widget.pubQRKey;
    String pubKey;
    return Scaffold(
        appBar: AppBar(title: Text("Create a Group")),
        body: Center(
            child: ListView(
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
                          SecondQRScanner(widget.chat, widget.pubQRKey)),
                      );
                    },


                  ),
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        hintText: 'Group ID'),
                    controller: groupIDField,
                  ),
                  RaisedButton(
                    child: Text("Save Info"),
                    color: Colors.blue,
                    onPressed: (){
                      publicKeyAsString().then((String retPubKey){
                        pubKey = retPubKey;

                        ChatInfo newChat = ChatInfo(
                            pubKey: pubKey,
                            fingerprint: createFingerprint(pubKeyInit.toString()),
                            name: widget.chat.name,
                            symmetricKey: widget.chat.symmetricKey,
                            serverAddress: widget.chat.serverAddress,
                            groupID: groupIDField.text
                        );

                      insertChatInfo(newChat);
                      Navigator.popUntil(context, ModalRoute.withName('/'));

                      //Store in database

                      });
                      chats().then((var retVal){
                        print(retVal);
                      });



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
