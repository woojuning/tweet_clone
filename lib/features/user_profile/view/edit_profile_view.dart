import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/loading_page.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/theme/theme.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});
  static route() => MaterialPageRoute(
        builder: (context) => EditProfileView(),
      );

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  File? bannerImage;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: ref.read(currentUserDetailsProvider).value?.name ?? '');
    bioController = TextEditingController(
        text: ref.read(currentUserDetailsProvider).value?.bio ?? '');
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioController.dispose();
  }

  void pickBanner() async {
    final bannerfile = await pickImage();
    if (bannerfile != null) {
      setState(() {
        bannerImage = bannerfile;
      });
    }
  }

  void pickProfile() async {
    final profileFile = await pickImage();
    if (profileFile != null) {
      setState(() {
        profileImage = profileFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(UserProfileControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(UserProfileControllerProvider.notifier)
                  .updateUserProfile(
                    userModel: user!.copyWith(
                      name: nameController.text,
                      bio: bioController.text,
                    ),
                    context: context,
                    bannerFile: bannerImage,
                    profileFile: profileImage,
                  );
            },
            child: Text('Save'),
          ),
        ],
      ),
      body: isLoading || user == null
          ? Loader()
          : Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: pickBanner,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                            20,
                          )),
                          child: bannerImage != null
                              ? Image.file(
                                  bannerImage!,
                                  fit: BoxFit.fill,
                                )
                              : user.bannerPic.isEmpty
                                  ? Container(
                                      color: Pallete.blueColor,
                                    )
                                  : Image.network(
                                      user.bannerPic,
                                      fit: BoxFit.fill,
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: GestureDetector(
                          onTap: pickProfile,
                          child: profileImage != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(profileImage!),
                                  radius: 40,
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profilePic),
                                  radius: 40,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(
                      10,
                    ),
                    hintText: 'Name',
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(
                      10,
                    ),
                    hintText: 'Bio',
                  ),
                  maxLines: 4,
                ),
              ],
            ),
    );
  }
}
