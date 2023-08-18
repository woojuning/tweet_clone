import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:twitter_clone/features/tweet/views/hashtags_tweet_view.dart';
import 'package:twitter_clone/theme/pallet.dart';

class HashtagText extends StatelessWidget {
  final String text;
  HashtagText({super.key, required this.text});
  String hashtag = '';

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpans = [];
    //hashtag일때
    //www or http: 일때
    //기본일때

    text.split(' ').forEach(
      (element) {
        if (element.startsWith('#')) {
          textSpans.add(
            TextSpan(
                text: '$element ',
                style: TextStyle(
                  color: Pallete.blueColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(context, HashTagsTweetView.route(element));
                  }),
          );
        } else if (element.startsWith('www.') ||
            element.startsWith('https://')) {
          textSpans.add(
            TextSpan(
              text: '$element ',
              style: TextStyle(
                color: Pallete.blueColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          textSpans.add(
            TextSpan(
              text: '$element ',
              style: TextStyle(
                color: Pallete.whiteColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      },
    );

    return RichText(
        text: TextSpan(
      children: textSpans,
    ));
  }
}
