import 'package:flutter/widgets.dart';
import 'package:twitter_clone/theme/pallet.dart';

class HashtagText extends StatelessWidget {
  final String text;
  const HashtagText({super.key, required this.text});

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
            ),
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
