import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/enums/noticiation_type_enum.dart';
import 'package:twitter_clone/features/notifications/controller/notifications_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';

final UserProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
    tweetAPI: ref.watch(tweetAPIProvider),
    userAPI: ref.watch(userAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  );
});

final getUserTweetsProvider = FutureProvider.family((ref, String uid) async {
  final userProfileController =
      ref.watch(UserProfileControllerProvider.notifier);
  return userProfileController.getUserTweets(uid);
});

final getLatestUserDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return userAPI.getLatestUserData();
});

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final UserAPI _userAPI;
  final StorageAPI _strogaeAPI;
  final NotificationController _notificationController;
  UserProfileController(
      {required TweetAPI tweetAPI,
      required UserAPI userAPI,
      required StorageAPI storageAPI,
      required NotificationController notificationController})
      : _tweetAPI = tweetAPI,
        _userAPI = userAPI,
        _strogaeAPI = storageAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getUserTweets(String uid) async {
    //uid를 가져오려면
    final tweetList = await _tweetAPI.getUserTweets(uid);
    return tweetList.map((e) => Tweet.fromMap(e.data)).toList();
  }

  //database에 업데이트를 한다음 storage에도 저장을 해야하는건가?
  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    //bannerFile이 존재하면 userModel update
    state = true;
    if (bannerFile != null) {
      final bannerUrl = await _strogaeAPI
          .uploadImage([bannerFile]); //url로 바꿔서 list<String>으로 반환해줌.
      userModel = userModel.copyWith(
        bannerPic: bannerUrl[0],
      );
    }
    //profileFile이 존재하면 userModel update
    if (profileFile != null) {
      final profileUrl = await _strogaeAPI
          .uploadImage([profileFile]); //url로 바꿔서 list<String>으로 반환해줌.
      userModel = userModel.copyWith(
        profilePic: profileUrl[0],
      );
    }
    final res = await _userAPI.updateUserData(userModel);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        return Navigator.pop(context);
      },
    );
  }

  void followUser({
    required UserModel user,
    required UserModel currentUser,
    required BuildContext context,
  }) async {
    final followersList = user.followers;
    final followingList = currentUser.following;
    followersList.add(currentUser.uid);
    followingList.add(user.uid);
    final res = await _userAPI.updateUserData(
      user.copyWith(
        followers: followersList,
      ),
    );
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        final res2 = await _userAPI
            .updateUserData(currentUser.copyWith(following: followingList));
        res2.fold((l) => showSnackBar(context, l.message), (r) {
          _notificationController.createNotification(
            text: '${currentUser.name}님이 follow 하셨습니다.',
            postId: user.uid,
            uid: user.uid,
            notificationType: NotificationType.follow,
          );
        });
      },
    );
  }
}
