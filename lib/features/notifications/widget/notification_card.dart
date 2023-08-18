import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone/constant/assets_constants.dart';
import 'package:twitter_clone/models/notification_model.dart';
import 'package:twitter_clone/theme/pallet.dart';

class NotificationCard extends ConsumerWidget {
  const NotificationCard({super.key, required this.model});
  final NotificationModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: model.notificationType.type == 'like'
          ? SvgPicture.asset(
              AssetsConstants.likeFilledIcon,
              color: Colors.red,
              height: 20,
            )
          : model.notificationType.type == 'follow'
              ? Icon(Icons.person)
              : model.notificationType.type == 'retweet'
                  ? SvgPicture.asset(AssetsConstants.retweetIcon)
                  : model.notificationType.type == 'reply'
                      ? null
                      : null,
      title: Text(
        model.text,
        style: TextStyle(
          color: Pallete.blueColor,
          fontSize: 20,
        ),
      ),
    );
  }
}
