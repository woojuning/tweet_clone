import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitter_clone/theme/pallet.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    if (currentUser == null) {
      return Loader();
    }
    return SafeArea(
      child: Drawer(
        backgroundColor: Pallete.backgroundColor,
        child: Column(children: [
          SizedBox(
            height: 50,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'My Profile',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            onTap: () {
              Navigator.push(context, UserProfileView.route(user: currentUser));
            },
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text(
              'My Cash',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'Log Out',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            onTap: () {},
          ),
        ]),
      ),
    );
  }
}
