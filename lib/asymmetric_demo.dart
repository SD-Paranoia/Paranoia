import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:steel_crypt/PointyCastleN/asymmetric/api.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'encryption_functions.dart';

class AsymmetricDemo extends StatefulWidget{
  @override
  _AsymmetricDemoState createState() => _AsymmetricDemoState();
}

class _AsymmetricDemoState extends State<AsymmetricDemo>{
  String pubKey = "Press \"Gen Key Pair!\"";
  String privateKey = "Press \"Gen Key Pair!\"";
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Asymmetric Encryption Demo Widget")),
      body: Center(
        child: ListView(
          
          children: <Widget>[
            RaisedButton(
              child: Text("Gen Key Pair"),
              onPressed: (){
                generatePublicPrivateKeypair();
              },
            ),
            RaisedButton(
              child: Text("Update Key View"),
              onPressed:(){
                getPublicKey().then((RSAPublicKey retVal){
                  setState(() {
                    pubKey = RsaCrypt().encodeKeyToString(retVal);
                  });
                });
                getPrivateKey().then((RSAPrivateKey retVal){
                  setState(() {
                    privateKey = RsaCrypt().encodeKeyToString(retVal);
                  });
                });
              },
            ),
            Text("Public Key:\n $pubKey"),
            Text("Private Key: TO BE REMOVED\n$privateKey"),
          ],
        ),
      ),
    );
  }

}