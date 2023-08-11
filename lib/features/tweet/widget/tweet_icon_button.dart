// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone/theme/pallet.dart';

class TweetIconButton extends StatelessWidget {
  final String text;
  final String path;
  final VoidCallback onTap;
  const TweetIconButton({
    Key? key,
    required this.text,
    required this.path,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            path,
            color: Pallete.greyColor,
          ),
          SizedBox(
            width: 4,
          ),
          Container(
            margin: EdgeInsets.all(6),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Pallete.greyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
