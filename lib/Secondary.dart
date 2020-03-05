import 'package:flutter/material.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/file_functions.dart';


class Secondary extends StatefulWidget {

  @override
  _SecondaryState createState() => _SecondaryState();
}

class _SecondaryState extends State<Secondary> {
  String keyVal;

  final myController = TextEditingController();
  final name = TextEditingController();
  final pubkey = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Secondary Message Creator")),
        body: Center(
            child: Column(
                children: <Widget>[

                  Text("Here is where the camera API goes"),

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
                      //TODO -- store in database
                    },
                  )

                ])));
  }
}