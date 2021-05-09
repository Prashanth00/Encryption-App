import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:imagepicker/MyEncryptionDecryption.dart';
import 'package:flutter/material.dart';
import 'package:imagepicker/saveform.dart';
import 'dart:io';
import 'package:pointycastle/asymmetric/api.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';

import 'Operations.dart';

class Encrypt extends StatefulWidget {
  @override
  _EncryptState createState() => _EncryptState();
}

class _EncryptState extends State<Encrypt> {
  bool _isgranted = true;
  var filename = "No file selected";
  Random rand = new Random();
  var alg2encryptedtext, alg3encryptedtext, alg1encryptedtext;
  int v, d, c;
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

  _decryptData(encData) async {
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
    MyEncryptionDecryption.aeskeyvalue = aeskey;
    MyEncryptionDecryption.fernetkeyvalue = fernetkey;
    MyEncryptionDecryption.salsa20keyvalue = salsa20key;
  }

  Future selectImage(Directory dir) async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    File pfile;
    v = rand.nextInt(3);
    d = rand.nextInt(3);
    while (v == d) {
      d = rand.nextInt(3);
    }
    c = rand.nextInt(3);
    while (v == c || d == c) {
      c = rand.nextInt(3);
    }

    if (result != null) {
      pfile = File(result.files.single.path);

      PlatformFile file = result.files.first;
      if (filename == "No file selected") {
        setState(() {
          filename = file.name;
        });
      }
      print("file picked");
    } else {
      // User canceled the picker
    }
    var bytes = pfile.readAsBytesSync();

    int lengthree = bytes.length ~/ 3;

    alg1encryptedtext = MyEncryptionDecryption.enclist[v].encryptBytes(
        bytes.sublist(0, lengthree),
        iv: MyEncryptionDecryption.ivlist[v]);
    alg2encryptedtext = MyEncryptionDecryption.enclist[d].encryptBytes(
        bytes.sublist(lengthree, 2 * lengthree),
        iv: MyEncryptionDecryption.ivlist[d]);
    alg3encryptedtext = MyEncryptionDecryption.enclist[c].encryptBytes(
        bytes.sublist(2 * lengthree),
        iv: MyEncryptionDecryption.ivlist[c]);
    print("encrypted parts");

    var totaltext = alg1encryptedtext.bytes.toString() +
        'f' +
        alg2encryptedtext.bytes.toString() +
        's' +
        alg3encryptedtext.bytes.toString() +
        v.toString() +
        d.toString() +
        c.toString();

    print(totaltext);
    print(totaltext.runtimeType);
    var bytestotaltext = utf8.encode(totaltext);
    var totalencryptedtext = MyEncryptionDecryption.aesencrypter
        .encryptBytes(bytestotaltext, iv: MyEncryptionDecryption.aesiv);
    print(totalencryptedtext);

    String p1 = await Operations.writeData(
        totalencryptedtext.bytes, dir.path + '/$filename.aes');
    print("Encrypted and written successully");
    Fluttertoast.showToast(msg: 'Encrypted and stored successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Encryptor"),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings - Change Password',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SaveForm()));
              })
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  filename != "No file selected"
                      ? filename
                      : "No file selected",
                  style: TextStyle(fontSize: 18),
                )),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              width: 200,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                onPressed: () async {
                  if (_isgranted) {
                    Directory d = await Operations.getExternalVisibleDir;
                    selectImage(d);
                  } else {
                    print('no permission');
                    requestStoragePermission();
                  }
                },
                color: Colors.blue,
                child: Text(
                  'Encrypt',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
