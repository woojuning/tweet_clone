import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widget/tweet_card.dart';

class HashTagsTweetView extends ConsumerWidget {
  final String text;
  const HashTagsTweetView({super.key, required this.text});
  static route(String text) => MaterialPageRoute(
        builder: (context) => HashTagsTweetView(text: text),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$text'),
      ),
      body: ref.watch(getHasHashTagsTweetProvider(text)).when(
            data: (tweets) {
              return ListView.builder(
                itemCount: tweets.length,
                itemBuilder: (context, index) {
                  return TweetCard(tweet: tweets[index]);
                },
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => Loader(),
          ),
    );
  }
}
