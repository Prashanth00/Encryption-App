import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart';
import 'MyEncryptionDecryption.dart';
import 'Operations.dart';

class SaveForm extends StatefulWidget {
  @override
  _SaveFormState createState() => _SaveFormState();
}

class _SaveFormState extends State<SaveForm> {
  bool _isgranted = true;
  final _formkey = GlobalKey<FormState>();
  TextEditingController aesController =
      TextEditingController(text: MyEncryptionDecryption.aeskeyvalue);
  TextEditingController fernetController =
      TextEditingController(text: MyEncryptionDecryption.fernetkeyvalue);
  TextEditingController salsa20Controller =
      TextEditingController(text: MyEncryptionDecryption.salsa20keyvalue);
  @override
  void initState() {
    onstart();
    super.initState();
  }

  onstart() async {
    if (_isgranted) {
      Directory d = await Operations.getExternalVisibleDir;
      List<int> encData =
          await Operations.readData('/storage/emulated/0/MyEncFolder/pass.rsa');
      print(encData);

      var plainData = await _decryptData(encData);
    } else {
      print('no permission');
      requestStoragePermission();
    }
  }

  _decryptData(encData) async {
    // final publicKey = await parseKeyFromFile<RSAPublicKey>(
    //     '/storage/emulated/0/MyEncFolder/test/public.pem');
    // final privKey = await parseKeyFromFile<RSAPrivateKey>(
    //     '/storage/emulated/0/MyEncFolder/test/private.pem');
    final publicPem = await rootBundle.loadString('assets/public.pem');
    final publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;

    final privatePem = await rootBundle.loadString('assets/private.pem');
    final privKey = RSAKeyParser().parse(privatePem) as RSAPrivateKey;
    final rsaencrypter =
        Encrypter(RSA(publicKey: publicKey, privateKey: privKey));
    Encrypted enrsa = new Encrypted(encData);
    var plaintext = rsaencrypter.decryptBytes(enrsa);
    String fullplain = utf8.decode(plaintext);
    var aeskey = fullplain.substring(0, 32);
    var fernetkey = fullplain.substring(32, 64);
    var salsa20key = fullplain.substring(64);
    setState(() {
      aesController.text = aeskey;
      fernetController.text = fernetkey;
      salsa20Controller.text = salsa20key;
    });
  }

  requestStoragePermission() async {
    if (!await Permission.storage.isGranted) {
      PermissionStatus result = await Permission.storage.request();
      if (result.isGranted) {
        setState(() {
          _isgranted = true;
        });
      } else {
        _isgranted = false;
      }
    }
  }

  encrypt(Directory dir) async {
    //final publicKey = await parseKeyFromFile<RSAPublicKey>(
    //  '/storage/emulated/0/MyEncFolder/test/public.pem');
    //final privKey = await parseKeyFromFile<RSAPrivateKey>(
    //  '/storage/emulated/0/MyEncFolder/test/private.pem');
    final publicPem = await rootBundle.loadString('assets/public.pem');
    final publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;

    final privatePem = await rootBundle.loadString('assets/private.pem');
    final privKey = RSAKeyParser().parse(privatePem) as RSAPrivateKey;
    final rsaencrypter =
        Encrypter(RSA(publicKey: publicKey, privateKey: privKey));
    String total = MyEncryptionDecryption.aeskeyvalue.toString() +
        MyEncryptionDecryption.fernetkeyvalue.toString() +
        MyEncryptionDecryption.salsa20keyvalue.toString();

    var bytestotaltext = utf8.encode(total);
    var totalenc = rsaencrypter.encryptBytes(bytestotaltext);
    String p1 = await _writeData(totalenc.bytes, dir.path + '/pass.rsa');
    print("Password written successfully");
    Fluttertoast.showToast(msg: 'Password changed');
  }

  Future<String> _writeData(dataToWrite, fileNameWithPath) async {
    print("writing data");
    File f = File(fileNameWithPath);
    await f.writeAsBytes(dataToWrite);
    return f.absolute.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings - Change Password")),
      body: Container(
        child: Form(
          key: _formkey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  //initialValue: MyEncryptionDecryption.aeskeyvalue,
                  controller: aesController,
                  autovalidate: true,
                  obscureText: true,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'AES key cannot be empty';
                    } else if (value.length != 32) {
                      return "AES key should have length of 32";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'AES algorithm key',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'Enter key for AES algorithm'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  //initialValue: MyEncryptionDecryption.fernetkeyvalue,
                  controller: fernetController,
                  obscureText: true,
                  autovalidate: true,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Fernet key cannot be empty';
                    } else if (value.length != 32) {
                      return "Fernet key should have length of 32";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Fernet algorithm key',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'Fernet key for Fernet algorithm'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  //initialValue: MyEncryptionDecryption.salsa20keyvalue,
                  controller: salsa20Controller,
                  obscureText: true,
                  autovalidate: true,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Salsa20 key cannot be empty';
                    } else if (value.length != 32) {
                      return "Salsa20 key should have length of 32";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Salsa20 algorithm key',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'Enter key for Salsa20 algorithm'),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                child: SizedBox(
                  height: 50,
                  width: 200,
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                    onPressed: () async {
                      if (_isgranted) {
                        Directory d = await Operations.getExternalVisibleDir;
                        if (_formkey.currentState.validate()) {
                          setState(() {
                            MyEncryptionDecryption.aeskeyvalue =
                                aesController.text;
                            MyEncryptionDecryption.fernetkeyvalue =
                                fernetController.text;
                            MyEncryptionDecryption.salsa20keyvalue =
                                salsa20Controller.text;

                            //globals.firsttime = false;
                          });
                          encrypt(d);
                        } else {
                          print('no permission');
                          requestStoragePermission();
                        }

                        Navigator.popAndPushNamed(context, '/MyApp');
                        print(MyEncryptionDecryption.fernetkeyvalue);
                      }
                    },
                    color: Colors.blue,
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
