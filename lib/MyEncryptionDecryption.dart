import 'package:encrypt/encrypt.dart' as encrypt;

class MyEncryptionDecryption {
  static String aeskeyvalue, fernetkeyvalue, salsa20keyvalue;

  //for AES encryption
  static final key = encrypt.Key.fromUtf8(aeskeyvalue);
  static final aesiv = encrypt.IV.fromLength(16);
  static final aesencrypter = encrypt.Encrypter(encrypt.AES(key));

  //for fernet encryption
  static final fernetkey = encrypt.Key.fromUtf8(fernetkeyvalue);
  static final fernet = encrypt.Fernet(fernetkey);
  static final fernetencrypter = encrypt.Encrypter(fernet);

  //for salsa encryption
  static final keysalsa = encrypt.Key.fromUtf8(salsa20keyvalue);
  static final ivsalsa = encrypt.IV.fromLength(8);
  static final salsaencrypter = encrypt.Encrypter(encrypt.Salsa20(keysalsa));

  static List enclist = [aesencrypter, fernetencrypter, salsaencrypter];
  static List ivlist = [aesiv, null, ivsalsa];
}
