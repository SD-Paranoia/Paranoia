//An app to demonstrate reading and writing to files on a device

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:steel_crypt/steel_crypt.dart';

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
  String keyVal, cipherText, lastIV;
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
  Future<String> readFromFile(String fileName) async {
    try {
      final filePath = await _localPath;
      File readFile = File('$filePath/$fileName');
      // Read the file
      String contents = await readFile.readAsString();
      // Returning the contents of the file
      return contents;
    } catch (e) {
      // If encountering an error, return
      return 'Error!';
    }
  }

  //A method to write to our file
  Future<File> writeToFile(String fileName, String text) async {
    final filePath = await _localPath;
    // Write the file
    File writeFile = File('$filePath/$fileName');
    return writeFile.writeAsString(text);
  }

  void generateSymmetricKey(){
    //Create a new 32 byte key and write it to a file
    writeToFile('symmetricKey.txt', CryptKey().genFortuna(32));

  }

  String encryptMsg(String key, String msg){
    AesCrypt encrypter = AesCrypt(key, 'gcm', 'pkcs7');
    lastIV = CryptKey().genDart(16);
    return encrypter.encrypt(msg, lastIV);
  }
  String decryptMsg(String key, String msg){
    try{
      AesCrypt decrypter = AesCrypt(key, 'gcm', 'pkcs7');
      return decrypter.decrypt(msg,lastIV);
    }catch(e){
      return 'Decryption error!';
    }
  }

  @override
  void initState() {
    super.initState();
    readFromFile('plain.txt').then((String value) {
      setState(() {
        data = value;
      });
    });
    readFromFile('symmetricKey.txt').then((String value){
      setState((){
        keyVal = value;
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
                  child: Text('Encrypt Message'),
                  color: Colors.blue,
                  onPressed: (){
                    writeToFile('msg.txt', encryptMsg(keyVal, myController.text));
                    readFromFile('msg.txt').then((String value) {
                      setState(() {
                        cipherText = value;
                      });
                    });
                  },
              ),
              RaisedButton(
                child: Text('Generate Symmetric Key'),
                color: Colors.green,
                onPressed: (){
                  generateSymmetricKey();
                  readFromFile('symmetricKey.txt').then((String value) {
                    setState(() {
                      keyVal = value;

                    });
                  });
                },
              ),
              // The text being printed on the screen
              Text(
                  'The plaintext is encrypted with key: $keyVal\n'
                      'The resulting ciphertext is:\n$cipherText'
              ),
              RaisedButton(
                child: Text('Decrypt Message'),
                color: Colors.yellow,
                onPressed: (){
                  readFromFile('msg.txt').then((String message) {
                    setState(() {
                      data = decryptMsg(keyVal, message);
                    });
                  });
                },
              ),
              // The text being printed on the screen
              Text(
                  'The decrypted text says:\n$data'
              ),
            ],
          ),
        ),
    );
  }
}