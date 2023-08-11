import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/constant/assets_constants.dart';
import 'package:twitter_clone/constant/ui_constants.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/theme/pallet.dart';

import '../../../core/core.dart';

class CreateTweetScreen extends ConsumerStatefulWidget {
  const CreateTweetScreen({super.key});
  static route() => MaterialPageRoute(
        builder: (context) => CreateTweetScreen(),
      );

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTweetScreenState();
}

class _CreateTweetScreenState extends ConsumerState<CreateTweetScreen> {
  final tweetTextController = TextEditingController();
  List<File> images = [];

  @override
  void dispose() {
    super.dispose();
    tweetTextController.dispose();
  }

  //실제로 tweet_view에서 tweetController의 shareTweet을 부르기 위한  method인듯
  void shareTweet() {
    ref.watch(tweetControllerProvider.notifier).shareTweet(
          images: images,
          text: tweetTextController.text,
          context: context,
        );
    Navigator.pop(context);
  }

  void onPickImages() async {
    images = await pickImages();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(tweetControllerProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close,
            ),
          ),
          actions: [
            RoundedSmallButton(
              onTap: shareTweet,
              label: 'Tweet',
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              textColor: Pallete.whiteColor,
            ),
          ],
        ),
        body: isLoading || currentUser == null
            ? Loader()
            : SafeArea(
                child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(currentUser.profilePic),
                          radius: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            controller: tweetTextController,
                            decoration: InputDecoration(
                              hintText: "What's happening?",
                              hintStyle: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              border: InputBorder.none,
                            ),
                            maxLines: null, //텍스트 라인을 무한으로 준다.
                          ),
                        ),
                      ],
                    ),
                    if (images.isNotEmpty)
                      CarouselSlider(
                        items: images.map(
                          (file) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              width: MediaQuery.of(context).size.width,
                              child: Image.file(file),
                            );
                          },
                        ).toList(),
                        options: CarouselOptions(
                          height: 400,
                          enableInfiniteScroll: false,
                        ),
                      ),
                  ],
                ),
              )),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Pallete.greyColor,
                width: 0.3,
              ),
            ),
          ),
          child: Row(children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: GestureDetector(
                  onTap: onPickImages,
                  child: SvgPicture.asset(AssetsConstants.galleryIcon)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: SvgPicture.asset(AssetsConstants.gifIcon),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: SvgPicture.asset(AssetsConstants.emojiIcon),
            ),
          ]),
        ),
      ),
    );
  }
}
