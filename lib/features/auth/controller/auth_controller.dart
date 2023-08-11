import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/auth_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/view/login_view.dart';
import 'package:twitter_clone/home/view/home_view.dart';
import 'package:appwrite/models.dart' as models;
import 'package:twitter_clone/models/user_model.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final currentUserDetailsProvider = FutureProvider((ref) {
  //이거는 현재 유저의 정보를 얻기 위함
  final currentUserId = ref.watch(currentUserProvider).value!.$id;
  final userDetails = ref.watch(userDetailsProvider(currentUserId)).value;
  return userDetails;
});

final userDetailsProvider = FutureProvider.family((ref, String uid) async {
  //이거는 원하는 유저의 정보를 얻기 위함
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid); //usermodel을 가져오는거지
});

final currentUserProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;
  AuthController({required AuthAPI authAPI, required UserAPI userAPI})
      : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);
  // nameparameter는 언더스코프를 가질 수 없는듯?

  Future<models.User?> currentUser() => _authAPI.currentUserAccount();

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => (l) {
        showSnackBar(
          context,
          l.message,
        );
      },
      (r) async {
        UserModel userModel = UserModel(
          email: email,
          name: getNameFromEmail(email),
          followers: [],
          following: [],
          profilePic: '',
          bannerPic: '',
          uid: r.$id,
          bio: '',
          isTwitterBlue: false,
        );
        final res2 = await _userAPI.SaveUserData(userModel);
        res2.fold(
          (l) => showSnackBar(context, l.message),
          (r) {
            showSnackBar(context, 'Accounted created! Please Login');
            Navigator.push(context, LoginView.route());
          },
        );
      },
    );
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true; //기다릴때 화면에 표시하는 인디케이터 true값
    final res = await _authAPI.login(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'login success!');
        Navigator.push(
          context,
          HomeView.route(),
        );
      },
    );
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userAPI.getUserData(uid);
    final updatedUser = UserModel.fromMap(document.data); //기록된 곳에서
    return updatedUser;
  }
}
