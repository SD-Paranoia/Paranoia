import 'package:flutter/material.dart';
import 'package:paranoia/asymmetric_encryption.dart';
import 'package:paranoia/database_functions.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/file_functions.dart';
import 'package:http/http.dart' as http;
import 'package:paranoia/database_demo.dart';
import 'package:paranoia/group_creation_primary.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'local_store.dart';
import 'package:paranoia/networking.dart';
import 'package:paranoia/CreateServer.dart';
import 'package:paranoia/GenerateKey.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Primary extends StatefulWidget {

  @override
  _PrimaryState createState() => _PrimaryState();
}

class _PrimaryState extends State<Primary> {

  final myController = TextEditingController();
  final name = TextEditingController();
  //final pubkey = TextEditingController();
  String body = "";
  String chatMsg = "";

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

  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Resend"),
      onPressed:  () {

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Registration Failed"),
      content: Text("Error sending registration to server!"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String keyVal;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x21ffffff),
        appBar: AppBar(title: Text("User Registration")),
        body: Center(
            child: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  Text("Enter Server and Chat Information",
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
                  RaisedButton(
                    child: Text('Generate keys'),
                    color: Colors.blue,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Fluttertoast.showToast(
                          msg: "Generating key. This may take a minute.",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          fontSize: 16.0
                      );
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
                            print(rsaVerify(key2, signedPublic, pubKey));
                          });
                        });


                          //Store the chat and keys into local database
                          String semkey = generateSymmetricKey();
                          ChatInfo chat = ChatInfo (pubKey: pubKey, name: name.text, symmetricKey: semkey, serverAddress: myController.text);
                          insertChatInfo(chat);

                      });

                      Fluttertoast.cancel();

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Group_Creation(myController.text)),
                      );
                    }
                  )

                ])));
  }
}