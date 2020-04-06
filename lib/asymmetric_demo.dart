import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:steel_crypt/PointyCastleN/asymmetric/api.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:paranoia/asymmetric_encryption.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:pointycastle/pointycastle.dart' as pc;


class AsymmetricDemo extends StatefulWidget{
  @override
  _AsymmetricDemoState createState() => _AsymmetricDemoState();
}

class _AsymmetricDemoState extends State<AsymmetricDemo>{
  String publicKey = "Press \"Gen Key Pair!\"";
  String privateKey = "Press \"Gen Key Pair!\"";
  String sampleText = "My Text";
  String signedText = "";
  String verifiedText = "Not Verified!";
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Asymmetric Encryption Demo Widget")),
      body: Center(
        child: ListView(
          
          children: <Widget>[
            Text("Some built-in text to sign/verify: $sampleText"),
            Text("Signed Text: $signedText"),
            RaisedButton(
              child: Text("Gen Key Pair"),
              onPressed: (){
                generatePublicPrivateKeypair();
              },
            ),
            RaisedButton(
              child: Text("Sign Message"),
              onPressed: (){
                getPrivateKey().then((pc.RSAPrivateKey privateKey){
                  setState(() {
                    signedText = rsaSign(privateKey, sampleText);
                  });
                });
              },
            ),
            RaisedButton(
              child: Text("Verify Signature"),
              onPressed: (){
                getPublicKey().then((pc.RSAPublicKey publicKey){
                  bool wasVerified = rsaVerify(publicKey, signedText, sampleText);
                  if(wasVerified == true){
                    setState(() {
                      verifiedText = "Verfied!";
                    });
                  }else{
                    setState(() {
                      verifiedText = "Not Verified!";
                    });
                  }
                });
              },
            ),
            Text("Verification? $verifiedText\n"),
            RaisedButton(
              child: Text("Update Key View"),
              onPressed:(){
                publicKeyAsString().then((String retVal){
                  setState(() {
                    publicKey = retVal;
                  });
                });
                privateKeyAsString().then((String retVal){
                  setState(() {
                    privateKey = retVal;
                  });
                });
              },
            ),
            Text("Public Key:\n $publicKey"),
            Text("Private Key: TO BE REMOVED\n$privateKey"),
          ],
        ),
      ),
    );
  }

}