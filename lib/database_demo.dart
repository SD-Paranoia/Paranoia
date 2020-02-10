import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database_functions.dart';

class DatabaseDemo extends StatefulWidget{
  @override
  _DatabaseDemoState createState() => _DatabaseDemoState();
}

class _DatabaseDemoState extends State<DatabaseDemo>{
  Database db;
  bool openCheck;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Database Demo Widget")),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Database: $db"),
            Text("Database open? $openCheck"),
            RaisedButton(
              child: Text("Open Database"),
              onPressed: (){
                openDB().then((Database retVal){
                  setState(() {
                    db = retVal;
                    openCheck = db.isOpen;
                  });
                });
              },
            ),
            RaisedButton(
              child: Text("Close Database"),
              onPressed: (){
                if(db.isOpen){
                  db.close().then((void val){
                    setState((){
                      openCheck = db.isOpen;
                      db = null;
                    });
                  });
                }
              },
            )
          ],
        )
      ),
    );
  }
}