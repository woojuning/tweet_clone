import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/apis/user_api2.dart';
import 'package:twitter_clone/constant/appwrite_constantts.dart';
import 'package:twitter_clone/constant/ui_constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/user_model.dart';

final userAPIProvider = Provider((ref) {
  return UserAPI(
      db: ref.watch(databases3Provider),
      realtime: ref.watch(realtime3Provider));
});

final userAPIv2Provider = Provider((ref) {
  return UserAPI(
      db: ref.watch(appwriteDatabaseProvider),
      realtime: ref.watch(appwriteRealTimeProvider));
});

abstract class IUserAPI {
  FutureEitherVoid SaveUserData(UserModel userModel);
  Future<Document> getUserData(String uid);
  Future<List<Document>> getUserByName(String name);
  FutureEitherVoid updateUserData(UserModel userModel);
  Stream<RealtimeMessage> getLatestUserData();
}

class UserAPI implements IUserAPI {
  final Databases _db;
  final Realtime _realTime;

  UserAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realTime = realtime;

  @override
  FutureEitherVoid SaveUserData(UserModel userModel) async {
    try {
      await _db.createDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.userCollection,
        documentId: userModel.uid,
        data: userModel.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'unexpected error occur', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<Document> getUserData(String uid) {
    return _db.getDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.userCollection,
        documentId: uid);
  }

  @override
  Future<List<Document>> getUserByName(String name) async {
    final documents = await _db.listDocuments(
      databaseId: AppWriteConstants.databaseId,
      collectionId: AppWriteConstants.userCollection,
      queries: [
        Query.search('name', name),
      ],
    );
    return documents.documents;
  }

  @override
  FutureEitherVoid updateUserData(UserModel userModel) async {
    try {
      await _db.updateDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.userCollection,
        documentId: userModel.uid,
        data: userModel.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Exeption Error Occurs', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Stream<RealtimeMessage> getLatestUserData() {
    return _realTime.subscribe(
      [
        'databases.${AppWriteConstants.databaseId}.collections.${AppWriteConstants.userCollection}.documents',
      ],
    ).stream;
  }

  Stream<RealtimeMessage> getNowDataRealtime() {
    return _realTime.subscribe([
      'databases.${AppWriteConstants.databaseId}.collections.${AppWriteConstants.userCollection}.documents'
    ]).stream;
  }
}

final getNowDataRealTimeProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return userAPI.getNowDataRealtime();
});
