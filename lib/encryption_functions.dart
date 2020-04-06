import 'package:steel_crypt/PointyCastleN/export.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:paranoia/asymmetric_encryption.dart';
//A function to generate a 32 byte (256 bit) symmetric key
String generateSymmetricKey(){
  //Create a new 32 byte key
  return CryptKey().genFortuna(32);

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
//A function to get the public key as a string
Future<String> publicKeyAsString() async{
  RSAPublicKey publicKey;
  Map<String, dynamic> keyVals = await getKeyVals("public");
  publicKey = RSAPublicKey(
      BigInt.tryParse(keyVals["n"]),
      BigInt.tryParse(keyVals["e"])
  );
  return RsaCrypt().encodeKeyToString(publicKey);
}
//A function to get the private key as a string
Future<String> privateKeyAsString() async{
  RSAPrivateKey privateKey;
  Map<String, dynamic> keyVals = await getKeyVals("private");
  privateKey = RSAPrivateKey(
      BigInt.tryParse(keyVals["n"]),
      BigInt.tryParse(keyVals["d"]),
      BigInt.tryParse(keyVals["p"]),
      BigInt.tryParse(keyVals["q"])
  );
  return RsaCrypt().encodeKeyToString(privateKey);
}