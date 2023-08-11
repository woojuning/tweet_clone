import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/constant/appwrite_constantts.dart';
import 'package:twitter_clone/core/core.dart';

final storageAPIProvider = Provider((ref) {
  return StorageAPI(storage: ref.watch(appwriteStorageProvider));
});

class StorageAPI {
  final Storage _storage;
  StorageAPI({required Storage storage}) : _storage = storage;

  Future<List<String>> uploadImage(List<File> files) async {
    //return 할 변수 여기서는 List<String> type의 변수를 생성한다.
    List<String> imageLinks = [];
    for (final file in files) {
      final uploadedFile = await _storage.createFile(
        bucketId: AppWriteConstants.imagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path),
      );
      imageLinks.add(AppWriteConstants.imageUrl(uploadedFile.$id));
    }
    return imageLinks;
  }
}
