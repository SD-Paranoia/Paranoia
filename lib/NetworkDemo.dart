import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paranoia/networking.dart';
import 'package:http/http.dart' as http;


class NetworkDemo extends StatefulWidget {
  @override
  _NetworkDemoState createState() => _NetworkDemoState();
}

class _NetworkDemoState extends State<NetworkDemo> {
  String msg = "Hello World number 2";
  String fingerPrint = "No thanks";
  String ipPort = "http://localhost:5000";
  String body = "";
  int responseCode = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Networking Demo")),
        body: Center(
        child: Column(
        children: <Widget>[
          Text("Networking"),
          RaisedButton(
          child: Text("Post request"),
            onPressed: (){
              sendMsg(msg, fingerPrint, ipPort).then((http.Response retVal){
                setState(() {
                  body = retVal.body;
                  responseCode = retVal.statusCode;
                });
              });
            }

          ),
          Text("Response Body: $body"),
          Text("Reponse Code: $responseCode")
    ])));


  }
}
