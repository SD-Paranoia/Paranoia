import 'dart:math';
import 'dart:typed_data';

import 'package:paranoia/file_functions.dart';
import 'package:steel_crypt/PointyCastleN/api.dart';
import 'package:steel_crypt/PointyCastleN/export.dart';
import 'package:steel_crypt/steel_crypt.dart';
//A function to generate a 32 byte (256 bit) symmetric key
String generateSymmetricKey(){
  //Create a new 32 byte key
  return CryptKey().genFortuna(32);

}
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
  SecureRandom secureRandom = getSecureRandom();
  final rsaParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64);
  final keyGen = RSAKeyGenerator();
  keyGen.init(ParametersWithRandom(rsaParams, secureRandom));

  final pair = keyGen.generateKeyPair();

  final public = pair.publicKey as RSAPublicKey;
  final private = pair.privateKey as RSAPrivateKey;

  //Write the public and private keys to files in the PEM format
  writeToFile("publicKey.pem",  RsaCrypt().encodeKeyToString(public));
  writeToFile("privateKey.pem", RsaCrypt().encodeKeyToString(private));

}
//Get the device owner's public key
Future<RSAPublicKey> getPublicKey() async{
  RSAPublicKey key;
  String pemString = await readFromFile("publicKey.pem");
  key = RsaCrypt().parseKeyFromString(pemString);
  return key;
}

//Get the device owner's private key
Future<RSAPrivateKey> getPrivateKey() async{
  RSAPrivateKey key;
  String pemString = await readFromFile("privateKey.pem");
  key = RsaCrypt().parseKeyFromString(pemString);
  return key;
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