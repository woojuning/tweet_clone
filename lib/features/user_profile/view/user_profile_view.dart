import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/constant/appwrite_constantts.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/features/user_profile/widget/user_profile.dart';
import 'package:twitter_clone/models/user_model.dart';

class UserProfileView extends ConsumerWidget {
  static route({required UserModel user}) => MaterialPageRoute(
        builder: (context) => UserProfileView(user: user),
      );
  final UserModel user;
  const UserProfileView({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = user;
    return Scaffold(
      body: ref.watch(getLatestUserDataProvider).when(
            data: (data) {
              if (data.events.contains(
                'databases.*.collections.${AppWriteConstants.userCollection}.documents.${copyOfUser.uid}.update',
              )) {
                copyOfUser = UserModel.fromMap(data.payload);
              }
              return UserProfile(user: copyOfUser);
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => UserProfile(user: copyOfUser),
          ),
    );
  }
}
