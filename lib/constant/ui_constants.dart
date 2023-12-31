// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone/features/explore/view/explore_view.dart';
import 'package:twitter_clone/features/notifications/view/notification_view.dart';
import 'package:twitter_clone/features/tweet/widget/tweet_list.dart';

import 'constants.dart';

class UIConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.twitterLogo,
        color: Colors.blue,
        height: 30,
      ),
      centerTitle: true,
    );
  }

  static List<Widget> bottomTabBarPages = [
    TweetList(),
    ExploreScreen(),
    NotificationView(),
  ];

  static List<Widget> jooyoungList = [
    Image.asset('assets/images/1.jpg'),
    Image.asset('assets/images/2.jpg'),
    Image.asset('assets/images/3.jpg'),
    Image.asset('assets/images/4.jpg'),
    Image.asset('assets/images/5.jpg'),
    Image.asset('assets/images/6.jpg'),
  ];
}
