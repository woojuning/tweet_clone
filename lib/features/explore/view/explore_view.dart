import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/features/explore/controller/explore_controller.dart';
import 'package:twitter_clone/features/explore/widget/search_tile.dart';
import 'package:twitter_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitter_clone/theme/theme.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarOutlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: Pallete.searchBarColor),
    );
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: TextField(
            onSubmitted: (value) {
              setState(() {
                isShowUsers = true;
              });
            },
            controller: searchController,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10).copyWith(left: 20),
                fillColor: Pallete.searchBarColor,
                filled: true,
                enabledBorder: appBarOutlineBorder,
                focusedBorder: appBarOutlineBorder,
                hintText: 'Search Twitter'),
          ),
        ),
      ),
      body: isShowUsers
          ? ref.watch(searchUserProvider(searchController.text)).when(
                data: (users) {
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return SearchTile(
                        userModel: user,
                      );
                    },
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => SizedBox(),
              )
          : SizedBox(),
    );
  }
}
