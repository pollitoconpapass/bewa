import 'package:encrypt/encrypt.dart';

String encryptPassword(String password) {
  final key = Key.fromLength(32);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  return encrypter.encrypt(password, iv: iv).base64;
}

String decryptPassword(String encryptedPassword) {
  final key = Key.fromLength(32);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  return encrypter.decrypt64(encryptedPassword, iv: iv);
}
