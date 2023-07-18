import 'package:app_auth/features/user/data/models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
}
