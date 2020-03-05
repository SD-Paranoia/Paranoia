import 'package:flutter/material.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/file_functions.dart';
import 'package:http/http.dart' as http;
import 'package:paranoia/database_demo.dart';
import 'local_store.dart';
import 'package:paranoia/networking.dart';
import 'package:paranoia/CreateServer.dart';
import 'package:paranoia/GenerateKey.dart';


class Primary extends StatefulWidget {

  @override
  _PrimaryState createState() => _PrimaryState();
}

class _PrimaryState extends State<Primary> {

  final myController = TextEditingController();
  final name = TextEditingController();
  final pubkey = TextEditingController();
  String body = "";

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
        appBar: AppBar(title: Text("Primary Message Creator")),
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
                    child: Text('Generate Symmetric key'),
                    color: Colors.green,
                    onPressed: () {

                      //TODO -- store in database
                      generateSymmetricKey();
                      readFromFile('symmetricKey.txt').then((String value) {
                        setState(() {
                          keyVal = value;
                        });
                      });

                      //TODO -- Pull current user's pubkey from database
                      String pubkey2 = "";
                      registerUser(pubkey.text, pubkey2, myController.text).then((http.Response retVal) {
                        setState(() {
                          body = retVal.body;
                          if (retVal.statusCode != 200){
                            showAlertDialog(context);
                          }

                        });
                      });
                    },
                  )

                ])));
  }
}