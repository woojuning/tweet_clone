import 'dart:convert';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/enums/noticiation_type_enum.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/notifications/controller/notifications_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';

final tweetControllerProvider =
    StateNotifierProvider<TweetController, bool>((ref) {
  return TweetController(
    ref: ref,
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  );
});

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getRepliesToTweetProvider = FutureProvider.family((ref, Tweet tweet) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getRepliesToTweet(tweet);
});

final getLatestTweetProvider = StreamProvider((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getLatestTweet();
});

final getTweetByIdProvider = FutureProvider.family((ref, String id) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetById(id);
});

final getHasHashTagsTweetProvider =
    FutureProvider.family((ref, String hashtags) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getHasHashTagsTweet(hashtags);
});

//트윗 컨트롤러
class TweetController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _stroageAPI;
  final Ref _ref;
  final NotificationController _notificationController;
  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required NotificationController notificationController,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _stroageAPI = storageAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getTweets() async {
    final tweetList = await _tweetAPI.getTweets();
    return tweetList.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  Future<List<Tweet>> getRepliesToTweet(Tweet tweet) async {
    final documentList = await _tweetAPI.getRepliesToTweet(tweet);
    final tweetList =
        documentList.map((tweet) => Tweet.fromMap(tweet.data)).toList();
    return tweetList;
  }

  Future<Tweet> getTweetById(String id) async {
    final document = await _tweetAPI.getTweetById(id);
    return Tweet.fromMap(document.data);
  }

  void likeTweet(Tweet tweet, UserModel user) async {
    List<String> likes = tweet.likes;
    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
    } else {
      likes.add(user.uid);
    }
    tweet = tweet.copyWith(likes: likes);
    final res = await _tweetAPI.likeTweet(tweet);
    res.fold((l) => print(l.message), (r) {
      _notificationController.createNotification(
        text: '${user.name} liked your tweet!',
        postId: tweet.id,
        uid: tweet.uid,
        notificationType: NotificationType.like,
      );
    }); // do not anything
  }

  void reshareTweet(
      Tweet tweet, UserModel currentUser, BuildContext context) async {
    tweet = tweet.copyWith(
      reshareCount: tweet.reshareCount + 1,
      retwetedBy: currentUser.name,
      likes: [],
      commentIds: [],
      tweetedAt: DateTime.now(),
    );
    final res = await _tweetAPI.updateReshareCount(tweet);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        tweet = tweet.copyWith(
          id: ID.unique(),
          reshareCount: 0,
        );
        final res2 = await _tweetAPI.shareTweet(tweet);

        res2.fold(
          (l) => showSnackBar(context, l.message),
          (r) {
            showSnackBar(context, 'ReTweet!');
            _notificationController.createNotification(
              text: '${currentUser.name} retweet your tweet!',
              postId: tweet.id,
              uid: tweet.uid,
              notificationType: NotificationType.retweet,
            );
          },
        );
      },
    );
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, 'Please enter text');
      return;
    }
    if (images.isNotEmpty) {
      _shareImageTweet(
        images: images,
        text: text,
        context: context,
        repliedTo: repliedTo,
      );
    } else {
      //이미지가 없는 상태
      _shareTextTweet(
        text: text,
        context: context,
        repliedTo: repliedTo,
      );
    }
  }

  void _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
  }) async {
    state = true; //Loading indicator start 기다리는 효과를 화면에 표시
    final hashtags = _getHashtagsFromText(text);
    final link = _getLinkFromText(text);
    final user = _ref.watch(currentUserDetailsProvider).value!;
    final imagesLinks = await _stroageAPI.uploadImage(images);

    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imagesLinks,
      uid: user.uid,
      tweetType: TweetType.image,
      tweetedAt: DateTime.now(),
      likes: [],
      commentIds: [],
      id: '',
      reshareCount: 0,
      retwetedBy: '',
      repliedTo: repliedTo,
    );
    final res = await _tweetAPI.shareTweet(tweet);

    state = false;

    res.fold(
      (l) => showSnackBar(
        context,
        l.message,
      ),
      (r) {
        showSnackBar(context, 'good');
      },
    );
  }

  void _shareTextTweet({
    required String text,
    required BuildContext context,
    required String repliedTo,
  }) async {
    state = true; //Loading indicator start 기다리는 효과를 화면에 표시
    final hashtags = _getHashtagsFromText(text);
    final link = _getLinkFromText(text);
    final user = _ref.watch(currentUserDetailsProvider).value!;
    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: [],
      uid: user.uid,
      tweetType: 'kimwoonjun'.toTweetTypeEnum(), //여기 부분이 이해가 안가는구만 ㅎㅎㅎㅎ
      tweetedAt: DateTime.now(),
      likes: [],
      commentIds: [],
      id: '',
      reshareCount: 0,
      retwetedBy: '',
      repliedTo: repliedTo,
    );
    final res = await _tweetAPI.shareTweet(tweet);

    state = false;

    res.fold(
      (l) => showSnackBar(
        context,
        l.message,
      ),
      (r) {
        print('success!');
        showSnackBar(context, 'tweet Success');
      },
    );
  }

  String _getLinkFromText(String text) {
    //text로부터 link를 구분해서 반환해주는 함수
    String link = '';
    List<String> wordsInSentence = text.split(' ');
    for (final word in wordsInSentence) {
      if (word.startsWith('http://') || word.startsWith('www.')) {
        link = word;
      }
    }
    return link;
  }

  List<String> _getHashtagsFromText(String text) {
    //text로부터 해쉬태그를 구분해서 반환해주는 함수
    List<String> hashtags = [];
    List<String> wordsInSentence = text.split(' ');
    for (final word in wordsInSentence) {
      if (word.startsWith('#')) {
        hashtags.add(word);
      }
    }
    return hashtags;
  }

  Future<List<Tweet>> getHasHashTagsTweet(String hastags) async {
    final documents = await _tweetAPI.getHasHashTagsTweet(hastags);
    return documents.map((e) => Tweet.fromMap(e.data)).toList();
  }
}
