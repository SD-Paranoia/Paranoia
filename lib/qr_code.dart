import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paranoia/database_functions.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  ChatInfo newChat, chat;
  String success;
  final myController = TextEditingController();

  ChatInfo createNewChat(String id){
    return ChatInfo(
      pubKey: id,
      name: "User_" + id,
      symmetricKey: CryptKey().genFortuna(32),
    );
  }

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    success = '';
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
            flex: 4,
          ),
          Expanded(
            child: Column(children:
              <Widget>[
                Text("This is the result of scan: $qrText"),
                RaisedButton(
                  onPressed: (){
                    if(controller != null){
                      controller.flipCamera();
                    }
                  },
                  child: Text(
                      'Flip',
                      style: TextStyle(fontSize: 20)
                  ),
                ),
                RaisedButton(
                  child: Text("Insert Into Database"),
                  onPressed: () {
                    newChat = createNewChat(qrText);
                    insertChatInfo(newChat).then((void retVal) {
                        setState(() {
                          chat = newChat;
                          success = "Added new chat: $chat";
                        });
                    }, onError: (e){
                      setState(() {
                        success = "Failed to add chat";
                      });
                    });
                  }),
              Text(success)
              ],
            ),
            flex: 1,
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
      });
    });
  }
}
/*
class _InsertChatState extends State<InsertChatDemo>{
  ChatInfo newChat, chat;
  String success;
  final myController = TextEditingController();

  ChatInfo createNewChat(String id){
    return ChatInfo(
      pubKey: id,
      name: "User_" + id,
      symmetricKey: CryptKey().genFortuna(32),
    );
  }

  //Needed to cleanup the text editing controller and free
  // its resources
  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    success = '';
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text("Insert Into Database")),
        body: Center(
          child: Column(
            children: <Widget>[
              // The text entry field
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter a unique ID (A Public Key perhaps)'
                ),
                controller: myController,
              ),
              RaisedButton(
                  child: Text("Insert Into Database"),
                  onPressed: () {
                    newChat = createNewChat(myController.text);
                    insertChatInfo(newChat).then((void retVal) {
                        setState(() {
                          chat = newChat;
                          success = "Added new chat: $chat";
                        });
                    }, onError: (e){
                      setState(() {
                        success = "Failed to add chat";
                      });
                    });
                  }),
              Text(success)
            ]
          )
        )
    );
  }
}
   void _onQRViewCreated(QRViewController controller) {
    final channel = controller.channel;
    controller.init(qrKey);
    this.controller = controller;
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onRecognizeQR":
          dynamic arguments = call.arguments;
          setState(() {
            qrText = arguments.toString();
          });
      }
    });
  }
} */