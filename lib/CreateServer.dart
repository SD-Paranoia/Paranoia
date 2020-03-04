import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paranoia/networking.dart';
import 'package:http/http.dart' as http;


class CreateServer extends StatefulWidget {
  @override
  _CreateServerState createState() => _CreateServerState();
}

class _CreateServerState extends State<CreateServer> {
  String msg = "";
  String fingerPrint = "";
  String ipPort = "";
  String body = "";
  int responseCode = 0;
  final myController = TextEditingController();
  final myController2 = TextEditingController();

  //Needed to cleanup the text editing controller and free
  // its resources
  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void dispose2(){
    myController2.dispose();
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
      title: Text("Error Sending Message!"),
      content: Text("Message failed to send"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Create Server")),
        body: Center(
            child: Column(
                children: <Widget>[

                  RaisedButton(
                      child: Text("Exchange Key"),
                      onPressed: (){
                        sendMsg(myController.text, fingerPrint, "http://" + myController2.text).then((http.Response retVal){
                          setState(() {
                            body = retVal.body;
                            responseCode = retVal.statusCode;
                            if (responseCode != 200){
                              showAlertDialog(context);
                            }
                          });
                        });
                      }

                  ),
                  Text("Response Body: $body"),
                  Text("Reponse Code: $responseCode")
                ])));


  }
}
