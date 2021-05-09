import 'dart:convert';
import 'package:imagepicker/MyEncryptionDecryption.dart';
import 'package:flutter/material.dart';
import 'package:imagepicker/saveform.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Operations.dart';

class Decrypt extends StatefulWidget {
  @override
  _DecryptState createState() => _DecryptState();
}

class _DecryptState extends State<Decrypt> {
  bool _isgranted = true;
  var filename1 = "No file selected", filename, filepath, filepath1;

  Future<Directory> get getExternalVisibleDir async {
    if (await Directory('/storage/emulated/0/MyEncFolder').exists()) {
      final externalDir = Directory('/storage/emulated/0/MyEncFolder');
      return externalDir;
    } else {
      await Directory('/storage/emulated/0/MyEncFolder')
          .create(recursive: true);
      final externalDir = Directory('/storage/emulated/0/MyEncFolder');
      return externalDir;
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

  selectFile(Directory dir) async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      if (filename1 == "No file selected") {
        setState(() {
          filename1 = file.name;
        });
      }

      filename = filename1.replaceAll(".aes", "");
      filepath = file.path;

      print("file picked");
    } else {
      // User canceled the picker
    }

    _getNormalFile(filepath, filename, dir.path);
  }

  _getNormalFile(path, filename, path2) async {
    List<int> encData = await Operations.readData(path);
    print(encData);

    var plainData = await _decryptData(encData);
    String p = await Operations.writeData(plainData, path2 + '/$filename');
    print("file decrypted successfully");
    Fluttertoast.showToast(msg: 'Decrypted and stored successfully');
  }

  _decryptData(encData) {
    print('decrypting.......');
    print(encData.length);
    encrypt.Encrypted enaes1 = new encrypt.Encrypted(encData);
    var totaltext = MyEncryptionDecryption.aesencrypter
        .decryptBytes(enaes1, iv: MyEncryptionDecryption.aesiv);
    print(totaltext.runtimeType);
    String fulltext = utf8.decode(totaltext);
    String stringtotaltext = fulltext.substring(0, fulltext.length - 3);

    String num = fulltext.substring(fulltext.length - 3);
    int v = int.parse(num[0]);
    int d = int.parse(num[1]);
    int c = int.parse(num[2]);
    print(stringtotaltext);
    var listconv1, listconv2, listconv3;
    List<int> dec1list = [], dec2list = [], dec3list = [];
    String dec1string,
        dec2string,
        dec3string,
        dec1string1,
        dec2string1,
        dec3string1;
    dec1string = stringtotaltext.substring(0, stringtotaltext.indexOf('f'));
    dec1string1 = dec1string.substring(1, dec1string.length - 1);
    listconv1 = dec1string1.split(',');
    for (int w = 0; w < listconv1.length; w++) {
      var o = int.parse(listconv1[w]);
      dec1list.add(o);
    }
    dec2string = stringtotaltext.substring(
        stringtotaltext.indexOf('f') + 1, stringtotaltext.indexOf('s'));
    dec2string1 = dec2string.substring(1, dec2string.length - 1);
    listconv2 = dec2string1.split(',');
    for (int w = 0; w < listconv2.length; w++) {
      var o = int.parse(listconv2[w]);
      dec2list.add(o);
    }
    dec3string = stringtotaltext.substring(stringtotaltext.indexOf('s') + 1);
    dec3string1 = dec3string.substring(1, dec3string.length - 1);
    listconv3 = dec3string1.split(',');
    for (int w = 0; w < listconv3.length; w++) {
      var o = int.parse(listconv3[w]);
      dec3list.add(o);
    }

    Uint8List dec1data = Uint8List.fromList(dec1list);
    encrypt.Encrypted endec1 = new encrypt.Encrypted(dec1data);
    var dec1plain = MyEncryptionDecryption.enclist[v]
        .decryptBytes(endec1, iv: MyEncryptionDecryption.ivlist[v]);
    Uint8List dec2data = Uint8List.fromList(dec2list);
    encrypt.Encrypted endec2 = new encrypt.Encrypted(dec2data);
    var dec2plain = MyEncryptionDecryption.enclist[d]
        .decryptBytes(endec2, iv: MyEncryptionDecryption.ivlist[d]);
    Uint8List dec3data = Uint8List.fromList(dec3list);
    encrypt.Encrypted endec3 = new encrypt.Encrypted(dec3data);
    var dec3plain = MyEncryptionDecryption.enclist[c]
        .decryptBytes(endec3, iv: MyEncryptionDecryption.ivlist[c]);
    return dec1plain + dec2plain + dec3plain; //until this 27.3
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Decryptor"),
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
                filename1 != "No file selected"
                    ? filename1
                    : "No file selected",
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: 200,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                onPressed: () async {
                  if (_isgranted) {
                    Directory d = await getExternalVisibleDir;
                    selectFile(d);
                  } else {
                    print('no permission');
                    requestStoragePermission();
                  }
                },
                color: Colors.blue,
                child: Text(
                  'Decrypt',
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
