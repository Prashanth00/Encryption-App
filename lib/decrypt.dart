import 'dart:convert';
import 'package:imagepicker/MyEncryptionDecryption.dart';
import 'package:flutter/material.dart';
import 'package:imagepicker/saveform.dart';
import 'dart:io';
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
    Fluttertoast.showToast(msg: 'Decrypted and stored successfully');
  }

  _decryptData(encData) {
    //DECRYPTION CODE
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
