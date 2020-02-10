//An app to demonstrate reading and writing to files on a device

import 'package:flutter/material.dart';
import 'file_functions.dart';
import 'encryption_functions.dart';

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
      appBar: AppBar(title: Text('Can we store things locally? Yes.')),
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