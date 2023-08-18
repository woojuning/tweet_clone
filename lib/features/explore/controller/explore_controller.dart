import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/models/user_model.dart';

final exploreControllerProvider =
    StateNotifierProvider<ExploreControllerNotifier, bool>((ref) {
  return ExploreControllerNotifier(userAPI: ref.watch(userAPIProvider));
});

final searchUserProvider = FutureProvider.family((ref, String name) {
  final exploreController = ref.watch(exploreControllerProvider.notifier);
  return exploreController.searchUser(name);
});

class ExploreControllerNotifier extends StateNotifier<bool> {
  final UserAPI _userAPI;
  ExploreControllerNotifier({required UserAPI userAPI})
      : _userAPI = userAPI,
        super(false);

  Future<List<UserModel>> searchUser(String name) async {
    final users = await _userAPI.getUserByName(name);
    return users.map((e) => UserModel.fromMap(e.data)).toList();
  }
}
