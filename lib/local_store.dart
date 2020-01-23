//An app to demonstrate reading and writing to files on a device

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    title: 'Creating Local Storage',
    home: LocalStorage(),
  ));
}

//Create a new stateful widget. This needs to be stateful since
// we're updating the data used by the widget
class LocalStorage extends StatefulWidget{
  @override
  _LocalStorageState createState() => _LocalStorageState();
}

//The state for the widget
class _LocalStorageState extends State<LocalStorage>{
  //The data to be printed on the screen
  String data = '';
  final myController = TextEditingController();

  //Needed to cleanup the text editing controller and free
  // its resources
  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  // An asynchronous method to get the path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    // print(directory.path);
    return directory.path;
  }

  // An asynchronous method to open a file for reading/writing
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/test.txt');
  }

  //A method to read from our file
  Future<String> readFromFile() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      // Returning the contents of the file
      return contents;
    } catch (e) {
      // If encountering an error, return
      return 'Error!';
    }
  }

  //A method to write to our file
  Future<File> writeToFile(String text) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(text);
  }

  @override
  void initState() {
    super.initState();
    readFromFile().then((String value){
      setState((){
        data = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Can we store things locally?')),
        body: Center(
          child: Column(
            children: <Widget>[
              // The text entry field
              TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write Something...'
                ),
                controller: myController,
              ),
              // The button that reads in the text from the field
              RaisedButton(
                  child: Text('Read Text'),
                  color: Colors.blue,
                  onPressed: (){
                    writeToFile(myController.text);
                    readFromFile().then((String value) {
                      setState(() {
                        data = value;
                      });
                    });
                  },
              ),
              // The text being printed on the screen
              Text(
                'The file now says:\n$data'
              ),
            ],
          ),
        ),
    );
  }
}