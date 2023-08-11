import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/constant/ui_constants.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/auth/view/login_view.dart';
import 'package:twitter_clone/features/auth/widgets/auth_field.dart';

import '../../../Common/common.dart';
import '../../../theme/theme.dart';

class SignUpview extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) {
          return SignUpview();
        },
      );
  const SignUpview({super.key});

  @override
  ConsumerState<SignUpview> createState() => _SignUpviewState();
}

class _SignUpviewState extends ConsumerState<SignUpview> {
  final appBar = UIConstants.appBar();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  //프로바이더로부터 메서드를 부를때는 항상 read를 이용해서 불러야한다. 왜냐면 계속 listen할 필요가 없기 때문인것 같은데?
  void onSignUp() {
    ref.read(authControllerProvider.notifier).signUp(
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
        appBar: appBar, //appbar는 고정된거임 아무리 loading indicator가 불려도
        body: isLoading
            ? Loader()
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
                            onTap: onSignUp,
                            label: 'Done',
                          ),
                        ),
                        // textspan
                        SizedBox(height: 40),
                        RichText(
                          text: TextSpan(
                            text: "Already have an account?",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: ' Login',
                                style: TextStyle(
                                  color: Pallete.blueColor,
                                  fontSize: 16,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      LoginView.route(),
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
