import 'package:encrypt/encrypt.dart';

class EncrypterHelper {
  static final _key = Key.fromUtf8('B?E(G+KbPeShVmYq3t6w9z\$C&F)J@McQ');
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String password) =>
      _encrypter.encrypt(password, iv: _iv).base64;

  static String decrypt(String encrypted) =>
      _encrypter.decrypt64(encrypted, iv: _iv);
}
