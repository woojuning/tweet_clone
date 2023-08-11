import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/auth/view/signup_view.dart';
import 'package:twitter_clone/home/view/home_view.dart';
import 'Common/common.dart';
import 'theme/theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: AppTheme.theme,
        home: ref.watch(currentUserProvider).when(
              data: (user) {
                //로직
                if (user != null) {
                  return HomeView();
                }
                return SignUpview();
              },
              error: (error, stackTrace) => ErrorPage(
                error: error.toString(),
              ),
              loading: () => LoadingPage(),
            ));
  }
}
