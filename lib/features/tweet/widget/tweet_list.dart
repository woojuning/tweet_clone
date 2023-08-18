import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/constant/appwrite_constantts.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widget/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getTweetsProvider).when(
          data: (tweets) {
            return ref.watch(getLatestTweetProvider).when(
                  data: (data) {
                    var tweet = Tweet.fromMap(data.payload);
                    bool isTweetAlreadyPresent = false;
                    for (final tweetModel in tweets) {
                      if (tweetModel.id == tweet.id) {
                        isTweetAlreadyPresent = true;
                        break;
                      }
                    }
                    if (!isTweetAlreadyPresent) {
                      if (data.events.contains(
                          'databases.*.collections.${AppWriteConstants.tweetCollection}.documents.*.create')) {
                        tweets.insert(0, Tweet.fromMap(data.payload));
                      }
                    }
                    if (data.events.contains(
                        'databases.*.collections.${AppWriteConstants.tweetCollection}.documents.*.update')) {
                      // final startingPoint =
                      //     data.events[0].lastIndexOf('documents.');
                      // final endPoint = data.events[0].lastIndexOf('.update');
                      // final tweetId2 = data.events[0]
                      //     .substring(startingPoint + 10, endPoint);
                      // print(tweetId2);

                      final tweetId = tweet.id;
                      final oldTweet =
                          tweets.where((tweet) => tweet.id == tweetId).first;
                      print(oldTweet.id);
                      final index = tweets.indexOf(oldTweet);
                      tweets.removeAt(index);
                      tweets.insert(index, tweet);
                    }

                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        return TweetCard(
                          tweet: tweet,
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () {
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        return TweetCard(
                          tweet: tweet,
                        );
                      },
                    );
                  },
                );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loader(),
        );
  }
}
