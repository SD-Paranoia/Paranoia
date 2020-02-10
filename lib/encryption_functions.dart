import 'package:steel_crypt/steel_crypt.dart';
import 'file_functions.dart';

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