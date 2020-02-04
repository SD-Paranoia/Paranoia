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
  String keyVal, cipherText;
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

  //A function to generate a 32 byte (256 bit) symmetric key and store it
  void generateSymmetricKey(){
    //Create a new 32 byte key and write it to a file
    writeToFile('symmetricKey.txt', CryptKey().genFortuna(32));

  }

  //A function to encrypt a message using AES with a 256 bit key
  String encryptMsg(String key, String msg){
    AesCrypt encrypter = AesCrypt(key, 'gcm', 'pkcs7');
    //Generate a new IV for the message encryption
    String iv = CryptKey().genDart(16);
    //Create the message to be sent by encrypting the plaintext and prepending
    // the IV
    String newMessage = iv + encrypter.encrypt(msg, iv);
    return newMessage;
  }
  //A function to decrypt a message using AES with a 256 bit key
  String decryptMsg(String key, String msg){
    try{
      AesCrypt decrypter = AesCrypt(key, 'gcm', 'pkcs7');
      //Get IV from the first 16 bytes of the message
      String iv = msg.substring(0,16);
      //Get the encrypted text from the remaining portion of the message
      String decryptedMessage = msg.substring(16);
      //Decrypt the message using the IV from the message.
      return decrypter.decrypt(decryptedMessage,iv);
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