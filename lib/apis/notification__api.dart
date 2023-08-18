import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constant/appwrite_constantts.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/notification_model.dart';

final notificationAPIProvider = Provider((ref) {
  return NotificationAPI(
    db: ref.watch(databases3Provider),
    realtime: ref.watch(realtime3Provider),
  );
});

abstract class INotificationAPI {
  FutureEitherVoid createNotification(NotificationModel model);
}

class NotificationAPI implements INotificationAPI {
  final Databases _db;
  final Realtime _realtime;
  NotificationAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;
  @override
  FutureEitherVoid createNotification(NotificationModel model) async {
    try {
      await _db.createDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.notificationsCollectionId,
        documentId: ID.unique(),
        data: model.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Exception Error occurs', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  //notification collection에 event(create, delete, update ,,,,)가 발생하면 이벤트처리를 해주는 stream함수
  Stream<RealtimeMessage> getLatestNotifications() {
    return _realtime.subscribe(
      [
        'databases.${AppWriteConstants.databaseId}.collections.${AppWriteConstants.notificationsCollectionId}.documents'
      ],
    ).stream;
  }

  Future<List<Document>> getCurrentUserNotification(String uid) async {
    final documents = await _db.listDocuments(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.notificationsCollectionId,
        queries: [
          Query.equal('uid', uid),
        ]);
    return documents.documents;
  }
}
