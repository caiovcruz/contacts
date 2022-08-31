import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerHelper {
  static Future<File?> getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    return pickedFile != null ? File(pickedFile.path) : null;
  }

  static Future<File?> getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    return pickedFile != null ? File(pickedFile.path) : null;
  }

  static String getProfileImageFilesPath() => '/assets/images/profile/';

  static String getBackgroundProfileImageFilesPath() =>
      '/assets/images/profile/background/';

  static Future<File?> saveFileToExStorage(
      String fileName, File fileToSave, String pathToSave) async {
    Directory? appExStorageDirectory = await getExternalStorageDirectory();

    if (appExStorageDirectory != null) {
      if (!await Directory("${appExStorageDirectory.path}$pathToSave")
          .exists()) {
        await Directory("${appExStorageDirectory.path}$pathToSave")
            .create(recursive: true);
      }

      return await fileToSave
          .copy("${appExStorageDirectory.path}$pathToSave$fileName");
    }

    return null;
  }

  static Future<File?> getFileFromExStorage(
      String fileName, String pathToGet) async {
    Directory? appExStorageDirectory = await getExternalStorageDirectory();

    if (appExStorageDirectory != null &&
        await File("${appExStorageDirectory.path}$pathToGet$fileName")
            .exists()) {
      return File("${appExStorageDirectory.path}$pathToGet$fileName");
    }

    return null;
  }
}
