import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/file_functions.dart';
import 'package:paranoia/qr_code_scanner.dart';


class Secondary extends StatefulWidget {

  const Secondary({
    Key key,
  }) : super(key: key);

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
    qrcontroller?.dispose();
    super.dispose();
  }

  @override
  void dispose1(){
    name.dispose();
    super.dispose();
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController qrcontroller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Secondary Message Creator")),
        body: Center(
            child: Column(
                children: <Widget>[

                  Text("Here is where the camera API goes"),
                  Expanded(
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                    flex: 4,
                  ),
                  RaisedButton(
                    child: Text("Turn on Camera"),
                    color: Colors.greenAccent[400],
                    onPressed: (){
                      qrcontroller.resumeCamera();
                    },
                  ),
                  RaisedButton(
                    child: Text("Flip on Camera"),
                    color: Colors.greenAccent[400],
                    onPressed: (){
                      qrcontroller.flipCamera();
                    },
                  ),
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
  void _onQRViewCreated(QRViewController controller) {
    this.qrcontroller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
      });
    });
  }
}