import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone/constant/assets_constants.dart';
import 'package:twitter_clone/constant/ui_constants.dart';
import 'package:twitter_clone/features/tweet/views/create_tweet_view.dart';
import 'package:twitter_clone/theme/pallet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static route() {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeView();
      },
    );
  }

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _page = 0;
  final appBar = UIConstants.appBar();

  void onPageTap(int index) {
    setState(() {
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: appBar,
      body: IndexedStack(
        index: _page,
        children: UIConstants.bottomTabBarPages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, CreateTweetScreen.route());
        },
        child: Icon(
          Icons.add,
          color: Pallete.whiteColor,
          size: 28,
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _page,
        onTap: onPageTap,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _page == 0
                  ? AssetsConstants.homeFilledIcon
                  : AssetsConstants.homeOutlinedIcon,
              color: Pallete.whiteColor,
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.searchIcon,
              color: Pallete.whiteColor,
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _page == 2
                  ? AssetsConstants.notifFilledIcon
                  : AssetsConstants.notifOutlinedIcon,
              colorFilter:
                  ColorFilter.mode(Pallete.whiteColor, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}
