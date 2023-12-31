import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

String getNameFromEmail(String email) {
  return email.split('@')[0];
}

Future<List<File>> pickImages() async {
  List<File> images = [];
  final ImagePicker picker = ImagePicker();
  final imagesFiles = await picker.pickMultiImage();
  if (imagesFiles.isNotEmpty) {
    for (final image in imagesFiles) {
      images.add(File(image.path));
    }
  }
  return images;
}

Future<File?> pickImage() async {
  final imagePicker = ImagePicker();
  final imageFile = await imagePicker.pickImage(source: ImageSource.gallery);

  if (imageFile != null) {
    return File(imageFile.path);
  }
  return null;
}
