import 'package:paranoia/database_functions.dart';
import 'package:pointycastle/asymmetric/api.dart' as pc;
import 'package:steel_crypt/PointyCastleN/export.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:paranoia/asymmetric_encryption.dart';
//A function to generate a 32 byte (256 bit) symmetric key
String generateSymmetricKey(){
  //Create a new 32 byte key
  return CryptKey().genFortuna(32);

}
//A function to encrypt a message using AES with a 256 bit key
String encryptMsg(String key, String msg, pc.RSAPrivateKey privateKey){
  AesCrypt encrypter = AesCrypt(key, 'gcm', 'pkcs7');
  //Generate a new IV for the message encryption
  String iv = CryptKey().genDart(16);
  //Create the message to be sent by encrypting the plaintext and prepending
  // the IV
  String newMessage = iv + encrypter.encrypt(msg, iv);
  String signature = rsaSign(privateKey, newMessage);
  //Prepend signature and return
  newMessage = signature + newMessage;
  return newMessage;
}
//A function to decrypt a message using AES with a 256 bit key
String decryptMsg(String key, String msg, String publicKey){
  try{
    String decryptedMessage;
    AesCrypt decrypter = AesCrypt(key, 'gcm', 'pkcs7');
    //Get the signature from the message
    String signature = msg.substring(0, 344);
    //Get the message text and IV
    String message = msg.substring(344);
    //Get IV from the first 16 bytes of the message
    String iv = message.substring(0, 16);
    //Get the encrypted text from the remaining portion of the message
    String messageText = message.substring(16);

    if(rsaVerify(getPublicKeyFromString(publicKey), signature, message)){
      decryptedMessage = decrypter.decrypt(messageText,iv);
    }
    else{
      decryptedMessage = "MESSAGE INTEGRITY VERIFICATION FAILED";
    }

    //Decrypt the message using the IV from the message.
    return decryptedMessage;
  }catch(e){
    return 'Decryption error: ' + e.toString();
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
//A function to get a pointycastle RSAPublicKey
// that can be used for verification from a PEM string
pc.RSAPublicKey getPublicKeyFromString(String publicKeyString){
  //Get the key from the PEM String, resulting in a steel_crypt RSA Public Key
  RSAPublicKey steelCryptKey = RsaCrypt().parseKeyFromString(publicKeyString);
  //Return a pointycastle RSAPublicKey that uses the steel_crypt key's modulus and exponent
  return pc.RSAPublicKey(steelCryptKey.n, steelCryptKey.e);
}