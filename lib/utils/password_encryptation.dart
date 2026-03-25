import 'package:encrypt/encrypt.dart';

final _key = Key.fromUtf8('12345678901234567890123456789012');
final _iv = IV.fromUtf8('1234567890123456');

String encryptPassword(String password) {
  final encrypter = Encrypter(AES(_key));
  return encrypter.encrypt(password, iv: _iv).base64;
}

String decryptPassword(String encryptedPassword) {
  final encrypter = Encrypter(AES(_key));
  return encrypter.decrypt64(encryptedPassword, iv: _iv);
}
