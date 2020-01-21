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

class LocalStorage extends StatefulWidget{
  @override
  _LocalStorageState createState() => _LocalStorageState();
}

class _LocalStorageState extends State<LocalStorage>{
  String data = '';
  final myController = TextEditingController();

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/test.txt');
  }

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

  Future<File> writeToFile(String text) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(text);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Can we store things locally?')),
        body: Center(
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write Something...'
                ),
                controller: myController,
              ),
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
              Text(
                'The file now says:\n$data'
              ),
            ],
          ),
        ),
    );
  }
}