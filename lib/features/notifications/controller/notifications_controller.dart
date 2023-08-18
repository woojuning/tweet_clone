import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/notification__api.dart';
import 'package:twitter_clone/core/enums/noticiation_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/models/notification_model.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  return NotificationController(
      notificationAPI: ref.watch(notificationAPIProvider));
});

final getLatestNotificationsProvider = StreamProvider((ref) {
  final notificationAPI = ref.watch(notificationAPIProvider);
  return notificationAPI.getLatestNotifications();
});

final getCurrentUserNotificationProvider = FutureProvider((ref) {
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  final currentUser = ref.watch(currentUserDetailsProvider).value;
  return notificationController.getCurrentUserNotification(currentUser!.uid);
});

class NotificationController extends StateNotifier<bool> {
  final NotificationAPI _notificationAPI;
  NotificationController({required NotificationAPI notificationAPI})
      : _notificationAPI = notificationAPI,
        super(false);

  void createNotification({
    required String text,
    required String postId,
    required String uid,
    required NotificationType notificationType,
  }) async {
    final res = await _notificationAPI.createNotification(
      NotificationModel(
        text: text,
        postId: postId,
        id: '',
        uid: uid,
        notificationType: notificationType,
      ),
    );
    res.fold((l) => print(l.message), (r) => null);
  }

  Future<List<NotificationModel>> getCurrentUserNotification(String uid) async {
    final doucments = await _notificationAPI.getCurrentUserNotification(uid);
    return doucments.map((e) => NotificationModel.fromMap(e.data)).toList();
  }
}
