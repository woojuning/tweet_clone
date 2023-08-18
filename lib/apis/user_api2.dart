// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/constant/appwrite_constantts.dart';
import 'package:twitter_clone/core/core.dart';

final userAPI2Provider = Provider((ref) {
  return UserAPI2(
    db: ref.watch(databases2Provider),
    realtime: ref.watch(realtime2Provider),
  );
});

final client2Provider = Provider((ref) {
  final client = Client();
  return client
      .setEndpoint(AppWriteConstants.endPoint)
      .setProject(AppWriteConstants.projectId)
      .setSelfSigned(
        status: true,
      );
});

final databases2Provider = Provider((ref) {
  return Databases(ref.watch(client2Provider));
});

final realtime2Provider = Provider((ref) {
  return Realtime(ref.watch(client2Provider));
});

final getRealtimeLatestDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPI2Provider);
  return userAPI.getRealtimeLatestData();
});

class UserAPI2 {
  final Databases db;
  final Realtime realtime;
  UserAPI2({
    required this.db,
    required this.realtime,
  });

  Stream<RealtimeMessage> getRealtimeLatestData() {
    return realtime.subscribe([
      'databases.${AppWriteConstants.databaseId}.collections.${AppWriteConstants.woojunCollectionId}.documents'
    ]).stream;
  }
}
