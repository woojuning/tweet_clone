import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/constant/assets_constants.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/views/twitter_reply_view.dart';
import 'package:twitter_clone/features/tweet/widget/carousel_image.dart';
import 'package:twitter_clone/features/tweet/widget/hashtag_text.dart';
import 'package:twitter_clone/features/tweet/widget/tweet_icon_button.dart';
import 'package:twitter_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';
import 'package:twitter_clone/theme/pallet.dart';
import 'package:timeago/timeago.dart' as timeago;

class TweetCard extends ConsumerWidget {
  final Tweet tweet;
  const TweetCard({super.key, required this.tweet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value ?? null;
    return ref.watch(userDetailsProvider(tweet.uid)).when(
          data: (user) {
            return currentUser == null
                ? SizedBox()
                : GestureDetector(
                    onTap: () {
                      Navigator.push(context, TwitterReplyScreen.route(tweet));
                    },
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context, UserProfileView.route(user: user));
                              },
                              child: Container(
                                margin: EdgeInsets.all(10),
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profilePic),
                                  radius: 35,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (tweet
                                      .retwetedBy.isNotEmpty) //리트윗된거를 표시하기 위해
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          AssetsConstants.retweetIcon,
                                          color: Pallete.greyColor,
                                        ),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          '${tweet.retwetedBy} retweeted',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Pallete.greyColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        child: Text(
                                          user.name,
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '@${user.name} . ${timeago.format(tweet.tweetedAt, locale: 'en_short')}',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Pallete.greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // replied to
                                  if (tweet.repliedTo
                                      .isNotEmpty) //다른 tweet을 reply 한 tweet이라면
                                    ref
                                        .watch(getTweetByIdProvider(
                                            tweet.repliedTo))
                                        .when(
                                          data: (repliedTweet) {
                                            final userModel = ref
                                                .watch(userDetailsProvider(
                                                    repliedTweet.uid))
                                                .value;
                                            return RichText(
                                              text: TextSpan(
                                                text: 'replied to',
                                                style: TextStyle(
                                                  color: Pallete.greyColor,
                                                  fontSize: 16,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        ' @${userModel?.name}',
                                                    style: TextStyle(
                                                      color: Pallete.blueColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          error: (error, stackTrace) =>
                                              ErrorText(
                                                  error: error.toString()),
                                          loading: () => SizedBox(),
                                        ),

                                  HashtagText(text: tweet.text),
                                  if (tweet.tweetType == TweetType.image)
                                    CarouselImage(
                                      imagesLink: tweet.imageLinks,
                                    ),
                                  if (tweet.link.isNotEmpty) ...[
                                    SizedBox(
                                      height: 4,
                                    ),
                                    AnyLinkPreview(
                                      displayDirection:
                                          UIDirection.uiDirectionHorizontal,
                                      link: 'http://${tweet.link}',
                                    ),
                                  ],
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 10,
                                      right: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TweetIconButton(
                                          text: (tweet.commentIds.length +
                                                  tweet.reshareCount +
                                                  tweet.likes.length)
                                              .toString(),
                                          path: AssetsConstants.viewsIcon,
                                          onTap: () {},
                                        ),
                                        TweetIconButton(
                                          text: tweet.commentIds.length
                                              .toString(),
                                          path: AssetsConstants.commentIcon,
                                          onTap: () {},
                                        ),
                                        TweetIconButton(
                                          text: tweet.reshareCount.toString(),
                                          path: AssetsConstants.retweetIcon,
                                          onTap: () {
                                            ref
                                                .read(tweetControllerProvider
                                                    .notifier)
                                                .reshareTweet(tweet,
                                                    currentUser, context);
                                          },
                                        ),
                                        LikeButton(
                                          onTap: (isLiked) async {
                                            ref
                                                .read(tweetControllerProvider
                                                    .notifier)
                                                .likeTweet(tweet, currentUser);
                                            return !isLiked;
                                          },
                                          isLiked: tweet.likes
                                              .contains(currentUser.uid),
                                          size: 25,
                                          likeBuilder: (isLiked) {
                                            isLiked
                                                ? SvgPicture.asset(
                                                    AssetsConstants
                                                        .likeFilledIcon)
                                                : SvgPicture.asset(
                                                    AssetsConstants
                                                        .likeOutlinedIcon);
                                          },
                                          likeCount: tweet.likes.length,
                                          countBuilder:
                                              (likeCount, isLiked, text) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 2),
                                              child: Text(
                                                likeCount.toString(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: isLiked
                                                      ? Pallete.redColor
                                                      : Pallete.greyColor,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(Icons.share_outlined),
                                          iconSize: 25,
                                          color: Pallete.greyColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Divider(
                          color: Pallete.greyColor,
                        ),
                      ],
                    ),
                  );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loader(),
        );
  }
}
