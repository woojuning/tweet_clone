import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';

final tweetControllerProvider =
    StateNotifierProvider<TweetController, bool>((ref) {
  return TweetController(
    ref: ref,
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
  );
});

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getLatestTweetProvider = StreamProvider((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getLatestTweet();
});

class TweetController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _stroageAPI;
  final Ref _ref;
  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _stroageAPI = storageAPI,
        super(false);

  Future<List<Tweet>> getTweets() async {
    final tweetList = await _tweetAPI.getTweets();
    return tweetList.map((tweet) => Tweet.fromMap(tweet.data)).toList();
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
    res.fold((l) => null, (r) => null); // do not anything
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
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
      );
    } else {
      //이미지가 없는 상태
      _shareTextTweet(
        text: text,
        context: context,
      );
    }
  }

  void _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
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
}
