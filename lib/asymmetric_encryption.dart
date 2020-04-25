//A file to handle the asymmetric cryptography functionality. The steel_crypt
// library doesn't support many of the features we need, so I have moved
// the functionality here for more readable code and removal the use of
// conflicting functions

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:paranoia/encryption_functions.dart';
import 'package:paranoia/file_functions.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

//Get a SecureRandom value generator
SecureRandom getSecureRandom(){
  final SecureRandom randVal = FortunaRandom();
  final seedSource = Random.secure();
  final seeds = <int>[];
  //Populate seed list
  for(int i = 0; i < 32; i++){
    seeds.add(seedSource.nextInt(255));
  }
  //Use values from seed list to seed the SecureRandom value
  randVal.seed(KeyParameter(Uint8List.fromList(seeds)));

  return randVal;
}

//Generate and store an Asymmetric keypair
void generatePublicPrivateKeypair(){
  print("KeyGen Started");
  SecureRandom secureRandom = getSecureRandom();
  final rsaParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64);
  final keyGen = RSAKeyGenerator();
  keyGen.init(ParametersWithRandom(rsaParams, secureRandom));

  final pair = keyGen.generateKeyPair();

  final public = pair.publicKey as RSAPublicKey;
  final private = pair.privateKey as RSAPrivateKey;

  storePublicKey(public);
  storePrivateKey(private);

  print("KeyGen Done");
}

//Create and store a JSON object with the components needed to recreate the pubKey
void storePublicKey(RSAPublicKey key){
  Map<String, dynamic> keyMap = {
    "e" : key.e.toString(), //exponent as String
    "n" : key.n.toString()  //modulus as String
  };

  writeToFile("publicKeyValues.txt", json.encode(keyMap));

}
//Create and store a JSON object with the components needed to recreate the private key
void storePrivateKey(RSAPrivateKey key){
  Map<String, dynamic> keyMap = {
  "n" : key.n.toString(), //modulus as String
  "d" : key.d.toString(), //exponent as String
  "q" : key.p.toString(), //q as String
  "p" : key.q.toString()  //p as String
  };

  writeToFile("privateKeyValues.txt", json.encode(keyMap));

}


Future<Map<String, dynamic>> getKeyVals(String keyType) async{
  Map<String, dynamic> keyVals;
  if(keyType == "public"){
    String jsonString = await readFromFile("publicKeyValues.txt");
    Map<String, dynamic> keyVals = json.decode(jsonString);
    return keyVals;
  }
  else if(keyType == "private"){
    String jsonString = await readFromFile("privateKeyValues.txt");
    Map<String, dynamic> keyVals = json.decode(jsonString);
    return keyVals;
  }
  else{
    keyVals = null;
    return keyVals;
  }

}

//Get the device owner's public key
Future<RSAPublicKey> getPublicKey() async{
  RSAPublicKey key;
  Map<String, dynamic> keyVals = await getKeyVals("public");
  key = new RSAPublicKey(
      BigInt.tryParse(keyVals["n"]),
      BigInt.tryParse(keyVals["e"])
  );
  return key;
}

//Get the owner's public key fingerprint
Future getPublicFingerprint() async{
  //Get the public key into PEM format and encode
  var keyString = await publicKeyAsString();
  final key = utf8.encode(keyString);
  //Sha256 Hashit
  var fingerPrint = sha256.convert(key);
  //now return the fingerPrint
  return fingerPrint;
}

String createFingerprint(String publicKey){
  final key = utf8.encode(publicKey);
  var fingerprint = sha256.convert(key);
  return fingerprint.toString();
}

hashUUID(String uuid){
  return sha256.convert(utf8.encode(uuid));
}

//Get the device owner's private key
Future<RSAPrivateKey> getPrivateKey() async{
  RSAPrivateKey key;
  Map<String, dynamic> keyVals = await getKeyVals("private");
  key = new RSAPrivateKey(
      BigInt.tryParse(keyVals["n"]),
      BigInt.tryParse(keyVals["d"]),
      BigInt.tryParse(keyVals["p"]),
      BigInt.tryParse(keyVals["q"])
  );
  return key;
}

//Sign a message using RSA and return it's signature as a Base64 encoded String
// This message should be called by .then-ing a call to getPrivateKey()
String rsaSign(RSAPrivateKey privateKey, String message) {
  //Convert the message to bytes
  final messageBytes = utf8.encode(message);
  //Create a signer and initialize it using the privateKey
  final signer = Signer('SHA-256/RSA');
  signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
  //Generate the signature
  final RSASignature sig = signer.generateSignature(messageBytes);
  //Return the base64 encoded signature
  return Base64Encoder().convert(sig.bytes);
}

//Verify a message's integrity
// Param signature should be a Base64 encoded string
// This message should be called by .then-ing a call to getPublicKey()
bool rsaVerify(RSAPublicKey publicKey, String signature, String message){
  //Decode Base64 encoded signature for use in verification
  Uint8List decodedSignature = Base64Decoder().convert(signature);
  final sig = RSASignature(decodedSignature);
  //Create the verifier and initialize it ('false' parameter indicates it will be used for verification)
  final verifier = Signer('SHA-256/RSA');
  verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
  //Convert the message to bytes
  final messageBytes = utf8.encode(message);
  try{
    return verifier.verifySignature(messageBytes, sig);
  }on ArgumentError {
    return false;
  }
}



