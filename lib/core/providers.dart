import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/constant/appwrite_constantts.dart';

final appwriteClientProvider = Provider((ref) {
  final client = Client();
  return client
      .setEndpoint(AppWriteConstants.endPoint)
      .setProject(AppWriteConstants.projectId)
      .setSelfSigned(
        status: true,
      );
});

final appwriteAccountProvider = Provider(
  (ref) {
    final client = ref.watch(appwriteClientProvider);
    return Account(client);
  },
);

final appwriteDatabaseProvider = Provider((ref) {
  return Databases(ref.watch(appwriteClientProvider));
});

final appwriteStorageProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});

final appwriteRealTimeProvider = Provider((ref) {
  return Realtime(ref.watch(appwriteClientProvider));
});

final databases3Provider = Provider((ref) {
  return Databases(ref.watch(appwriteClientProvider));
});

final realtime3Provider = Provider((ref) {
  return Realtime(ref.watch(appwriteClientProvider));
});
