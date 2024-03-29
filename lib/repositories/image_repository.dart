import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageRepository {
  final FirebaseStorage _firebaseStorage;

  ImageRepository({FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  Future<Uint8List> _compressFile(
      {@required List<int> imageData, int quality = 20}) async {
    List<int> compressedImageData = await FlutterImageCompress.compressWithList(
        imageData,
        quality: quality);

    return Uint8List.fromList(compressedImageData);
  }

  Future<String> saveProfileAvatar(
      {@required String userId, @required Asset asset}) async {
    final uuid = Uuid();

    final String fileLocation = 'profile';
    final String fileName = '$userId/$fileLocation/${uuid.v1()}';

    ByteData byteData = await asset.requestOriginal();
    List<int> imageData = byteData.buffer.asUint8List();

    // compress file
    Uint8List compressedFile =
        await _compressFile(imageData: imageData, quality: 30);

    StorageReference reference = _firebaseStorage.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putData(compressedFile);
    StorageTaskSnapshot storageTaskSnapshot;

    // Release the image data
    // asset.releaseOriginal();

    StorageTaskSnapshot snapshot = await uploadTask.onComplete.timeout(
        const Duration(seconds: 60),
        onTimeout: () =>
            throw ('Upload could not be completed. Operation timeout'));

    if (snapshot.error == null) {
      storageTaskSnapshot = snapshot;
      return await storageTaskSnapshot.ref.getDownloadURL();
    } else {
      throw ('An error occured while uploading image. Upload error');
    }
  }
}
