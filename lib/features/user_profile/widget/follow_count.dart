import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:twitter_clone/theme/pallet.dart';

class FollowCount extends StatelessWidget {
  final int count;
  final String text;
  const FollowCount({super.key, required this.count, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          '$text',
          style: TextStyle(
            fontSize: 18,
            color: Pallete.greyColor,
          ),
        ),
      ],
    );
  }
}
