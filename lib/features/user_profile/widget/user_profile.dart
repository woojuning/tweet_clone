import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/widget/tweet_card.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/features/user_profile/view/edit_profile_view.dart';
import 'package:twitter_clone/features/user_profile/widget/follow_count.dart';
import 'package:twitter_clone/models/user_model.dart';
import 'package:twitter_clone/theme/pallet.dart';

import '../../../Common/loading_page.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;
  const UserProfile({
    super.key,
    required this.user,
  });

  bool checkFollow(UserModel currentUser) {
    final isFollowed =
        user.followers.where((element) => element == currentUser.uid).length > 0
            ? true
            : false;
    return isFollowed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 150,
            floating: true,
            snap: true,
            flexibleSpace: currentUser == null
                ? Loader()
                : Stack(
                    children: [
                      Positioned.fill(
                        child: user.bannerPic.isEmpty
                            ? Container(
                                color: Pallete.blueColor,
                              )
                            : Image.network(
                                user.bannerPic,
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 45,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: EdgeInsets.all(20),
                        child: OutlinedButton(
                          onPressed: () {
                            if (user.uid == currentUser.uid) {
                              Navigator.push(context, EditProfileView.route());
                            } else if (!checkFollow(currentUser)) {
                              ref
                                  .read(UserProfileControllerProvider.notifier)
                                  .followUser(
                                      user: user,
                                      currentUser: currentUser,
                                      context: context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Pallete.whiteColor,
                                width: 2,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 25),
                          ),
                          child: Text(
                            currentUser.uid == user.uid
                                ? 'Edit Profile'
                                : checkFollow(currentUser)
                                    ? 'unfollow'
                                    : 'follow',
                            style: TextStyle(
                              color: Pallete.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${user.name}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Pallete.greyColor,
                    ),
                  ),
                  Text(
                    user.bio,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      FollowCount(
                        count: user.following.length,
                        text: 'following',
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      FollowCount(
                        count: user.followers.length,
                        text: 'followers',
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Divider(
                    color: Pallete.whiteColor,
                    thickness: 2,
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: ref.watch(getUserTweetsProvider(user.uid)).when(
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
