import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../core/core.dart';

// want to signup, want to get user account -> Account
// want to access user related data -> models.User Account 에서 이름이 User로 바뀐듯?

final authAPIProvider = Provider((ref) {
  return AuthAPI(
      account: ref.watch(
    appwriteAccountProvider,
  ));
});

abstract class IAuthAPI {
  FutureEither<models.User> signUp({
    required String email,
    required String password,
  });

  FutureEither<models.Session> login({
    required String email,
    required String password,
  });

  Future<models.User?> currentUserAccount();
}

class AuthAPI implements IAuthAPI {
  final Account _account;
  String name = '';
  AuthAPI({
    required Account account,
  }) : _account = account;

  @override
  Future<models.User?> currentUserAccount() async {
    try {
      return await _account.get();
    } on AppwriteException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEither<models.User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final account = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }

  @override
  FutureEither<models.Session> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );
      return right(session);
    } on AppwriteException catch (e, stackTrace) {
      return left(
          Failure(e.message ?? 'Some unexpected error occurred', stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}
