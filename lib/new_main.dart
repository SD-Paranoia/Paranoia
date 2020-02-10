import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:steel_crypt/steel_crypt.dart';

void main(){
  runApp(MaterialApp(
    title: 'Paranoia',
    home: ParanoiaHome(),
  ));
}

class Paranoia extends StatefulWidget{
  @override
  _ParanoiaState createState() => _ParanoiaState();
}

@override
class MyKey extends ParanoiaHome {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Key'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Show key relationships"),
              onPressed: (){
                //Navigator.pop(context);
              },
            ),
            RaisedButton(
              child: Text("Go Back"),
              onPressed: (){
                  Navigator.pop(context);
                },
            ),
        ],
      ),
      ),
    );
  }
}

@override
class AddAKey extends Paranoia{

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Recipient\'s key'),
      ),
      body: Center(

      ),
    );
  }
}

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: Center(

      ),
    );
  }
}

class ParanoiaHome extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        leading: IconButton(
//          icon: Icon(Icons.menu),
//          tooltip: 'Navigation menu',
//          onPressed: null,
//        ),
        title: Text('Paranoia New'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('View my key relationships'),
              color: Colors.blue,
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyKey()));
              },
            ),
            RaisedButton(
              child: Text('Add a Recipient\'s key'),
              color: Colors.blue,
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddAKey()));
              },
            ),
            RaisedButton(
              child: Text('Chats'),
              color: Colors.blue,
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Chats()));
              },
            )
          ],
        ),
      ),
    );
  }
}

class _ParanoiaState extends State<Paranoia>{
  String data = '';
  String key, cipherText;
  final myController = TextEditingController();

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
        key = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate shared key')),
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
                writeToFile('msg.txt', encryptMsg(key, myController.text));
                readFromFile('msg.txt').then((String value) {
                  setState(() {
                    cipherText = value;
                  });
                });
              },
            ),
            RaisedButton(
              child: Text('Generate Key'),
              color: Colors.green,
              onPressed: (){
                generateSymmetricKey();
                readFromFile('symmetricKey.txt').then((String value) {
                  setState(() {
                    key = value;

                  });
                });
              },
            ),
            // The text being printed on the screen
            Text(
                'The plaintext is encrypted with key: $key\n'
                    'The resulting ciphertext is:\n$cipherText'
            ),
            RaisedButton(
              child: Text('Decrypt Message'),
              color: Colors.yellow,
              onPressed: (){
                readFromFile('msg.txt').then((String message) {
                  setState(() {
                    data = decryptMsg(key, message);
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