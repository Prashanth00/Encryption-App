import 'dart:io';

import 'dart:typed_data';

class Operations {
  static Future<String> writeData(dataToWrite, fileNameWithPath) async {
    print("writing data");
    File f = File(fileNameWithPath);
    await f.writeAsBytes(dataToWrite);
    return f.absolute.toString();
  }

  static Future<Uint8List> readData(fileNameWithPath) async {
    print("Reading data");
    File f = File(fileNameWithPath);
    return await f.readAsBytes();
  }

  static Future<Directory> get getExternalVisibleDir async {
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
}
