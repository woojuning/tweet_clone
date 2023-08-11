import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/Common/common.dart';
import 'package:twitter_clone/Common/rounded_small_button.dart';
import 'package:twitter_clone/apis/auth_api.dart';
import 'package:twitter_clone/constant/ui_constants.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/auth/view/signup_view.dart';
import 'package:twitter_clone/features/auth/widgets/auth_field.dart';
import 'package:twitter_clone/theme/pallet.dart';

class LoginView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) {
          return const LoginView();
        },
      );
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final appbar = UIConstants.appBar(); //final 로 선언이 되었기때문에 한번 불리면 끝.
  //TextEditingController를 사용해야하기 때문에 dispose가 있는 statelessWidget을 사용해야 한다.
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void onLogin() {
    ref.watch(authControllerProvider.notifier).login(
          email: emailController.text,
          password: passwordController.text,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: appbar, //appbar는 고정된거임 아무리 loading indicator가 불려도
        body: isLoading
            ? const Loader()
            : Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // textfield 1
                        AuthField(
                          controller: emailController,
                          hintText: 'Email',
                        ),
                        // textfield 2
                        SizedBox(
                          height: 25,
                        ),
                        AuthField(
                          controller: passwordController,
                          hintText: 'Password',
                        ),
                        SizedBox(height: 40),
                        // button
                        Align(
                          alignment: Alignment.topRight,
                          child: RoundedSmallButton(
                            onTap: onLogin,
                            label: 'Done',
                          ),
                        ),
                        // textspan
                        SizedBox(height: 40),
                        RichText(
                          text: TextSpan(
                            text: "Don't have an account?",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: ' Sign Up',
                                style: TextStyle(
                                  color: Pallete.blueColor,
                                  fontSize: 16,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      SignUpview.route(),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
