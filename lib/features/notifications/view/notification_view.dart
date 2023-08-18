import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/features/notifications/controller/notifications_controller.dart';
import 'package:twitter_clone/features/notifications/widget/notification_card.dart';
import 'package:twitter_clone/models/notification_model.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: ref.watch(getCurrentUserNotificationProvider).when(
            data: (notifications) {
              return ref.watch(getLatestNotificationsProvider).when(
                  data: (data) {
                    if (data.events.contains(
                        'databases.*.collections.*.documents.*.create')) {
                      notifications
                          .add(NotificationModel.fromMap(data.payload));
                    }
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return NotificationCard(
                          model: notifications[index],
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () {
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return NotificationCard(
                          model: notifications[index],
                        );
                      },
                    );
                  });
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => Loader(),
          ),
    );
  }
}
