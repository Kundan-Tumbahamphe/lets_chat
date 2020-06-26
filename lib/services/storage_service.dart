import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:lets_chat/utilities/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Future<File> _compressImage(String imageId, File image) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String path = tempDir.path;
    File compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/image_$imageId.jpg',
      quality: 70,
    );
    return compressedImageFile;
  }

  Future<String> _uploadImage(String path, File compressImage) async {
    StorageUploadTask uploadTask =
        storageRef.child(path).putFile(compressImage);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadChatImageAndGetDownloadUrl(
      {File imageFile, String url}) async {
    String imageId = Uuid().v4();

    File compressedImage = await _compressImage(imageId, imageFile);

    if (url != null) {
      RegExp exp = RegExp(r'chat_(.*).jpg');
      imageId = exp.firstMatch(url)[1];
    }

    String downloadUrl =
        await _uploadImage('images/chats/chat_$imageId.jpg', compressedImage);
    return downloadUrl;
  }

  Future<String> uploadMessageImageAndGetDownloadUrl(File imageFile) async {
    String imageId = Uuid().v4();

    File compressedImage = await _compressImage(imageId, imageFile);

    String downloadUrl = await _uploadImage(
        'images/messages/message_$imageId.jpg', compressedImage);
    return downloadUrl;
  }
}
