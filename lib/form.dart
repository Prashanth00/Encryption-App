import 'package:flutter/material.dart';
import 'package:imagepicker/MyEncryptionDecryption.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'Operations.dart';

class Formdetail extends StatefulWidget {
  @override
  _FormdetailState createState() => _FormdetailState();
}

class _FormdetailState extends State<Formdetail> {
  bool _isgranted = true;
  TextEditingController aesController =
      TextEditingController(text: MyEncryptionDecryption.aeskeyvalue);
  TextEditingController fernetController =
      TextEditingController(text: MyEncryptionDecryption.fernetkeyvalue);
  TextEditingController salsa20Controller =
      TextEditingController(text: MyEncryptionDecryption.salsa20keyvalue);
  String aeskey, fernetkey, salsa20key;
  final _formkey = GlobalKey<FormState>();

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
    String total = MyEncryptionDecryption.aeskeyvalue.toString() +
        MyEncryptionDecryption.fernetkeyvalue.toString() +
        MyEncryptionDecryption.salsa20keyvalue.toString();

    var bytestotaltext = utf8.encode(total);
    var totalenc = rsaencrypter.encryptBytes(bytestotaltext);
    String p1 =
        await Operations.writeData(totalenc.bytes, dir.path + '/pass.rsa');
    print("Password written successfully");
    Fluttertoast.showToast(msg: 'Password saved');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Password")),
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.done),
          onPressed: () async {
            if (_isgranted) {
              Directory d = await Operations.getExternalVisibleDir;
              if (_formkey.currentState.validate()) {
                setState(() {
                  MyEncryptionDecryption.aeskeyvalue = aesController.text;
                  MyEncryptionDecryption.fernetkeyvalue = fernetController.text;
                  MyEncryptionDecryption.salsa20keyvalue =
                      salsa20Controller.text;
                });
                encrypt(d);
                Navigator.popAndPushNamed(context, '/MyApp');
              }
            } else {
              print('no permission');
              requestStoragePermission();
            }

            //Navigator.popAndPushNamed(context, '/MyApp');
            print(MyEncryptionDecryption.fernetkeyvalue);
          }),
    );
  }
}
