import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/constant/constants.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widget/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';

class TwitterReplyScreen extends ConsumerWidget {
  final Tweet tweet;
  const TwitterReplyScreen({super.key, required this.tweet});

  static route(Tweet tweet) => MaterialPageRoute(
        builder: (context) {
          return TwitterReplyScreen(tweet: tweet);
        },
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Twoeet Reply')),
        body: Column(
          children: [
            TweetCard(tweet: tweet),
            ref.watch(getRepliesToTweetProvider(tweet)).when(
                  data: (tweets) {
                    return ref.watch(getLatestTweetProvider).when(
                          data: (data) {
                            final newTweet = Tweet.fromMap(data.payload);
                            bool isTweetAlreadyPresent = false; //이미 존재하는지 체크

                            for (final tweet in tweets) {
                              if (tweet.id == newTweet.id) {
                                //tweets안에 있는 tweet중 id가 제일 마지막에 들어온 tweet의 id랑 같으면 isTweetAlreadyPresent를 true로 주고 break;
                                isTweetAlreadyPresent = true;
                                break;
                              }
                            }

                            if (!isTweetAlreadyPresent &&
                                newTweet.repliedTo == tweet.id) {
                              if (data.events.contains(
                                  'databases.*.collections.${AppWriteConstants.tweetCollection}.documents.*.create')) {
                                tweets.add(Tweet.fromMap(data
                                    .payload)); //tweets 현재 마지막으로 생성된 tweet을 집어 넣는다.
                              } else if (data.events.contains(
                                  'databases.*.collections.${AppWriteConstants.tweetCollection}.documents.*.update')) {
                                final tweetId = newTweet.id;
                                final oldTweet = tweets
                                    .where((element) => element.id == tweetId)
                                    .first;
                                final index = tweets.indexOf(oldTweet);

                                tweets.removeAt(index);
                                tweets.insert(index, newTweet);
                              }
                            }

                            return Expanded(
                              child: ListView.builder(
                                itemCount: tweets.length,
                                itemBuilder: (context, index) {
                                  return TweetCard(
                                    tweet: tweets[index],
                                  );
                                },
                              ),
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () {
                            return Expanded(
                              child: ListView.builder(
                                itemCount: tweets.length,
                                itemBuilder: (context, index) {
                                  return TweetCard(
                                    tweet: tweets[index],
                                  );
                                },
                              ),
                            );
                          },
                        );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => Loader(),
                ),
          ],
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: TextField(
            onSubmitted: (value) {
              ref.read(tweetControllerProvider.notifier).shareTweet(
                images: [],
                text: value,
                context: context,
                repliedTo: tweet.id,
              );
            },
            decoration: InputDecoration(hintText: 'reply your tweet here'),
          ),
        ),
      ),
    );
  }
}
