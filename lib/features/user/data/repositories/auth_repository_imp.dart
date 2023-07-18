import 'package:app_auth/features/user/data/datasources/auth_datasource.dart';
import 'package:app_auth/features/user/domain/entities/user.dart';
import 'package:app_auth/features/user/domain/repositories/auth_repository.dart';
import 'package:app_auth/features/user/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthRepositoryImp implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImp(this.dataSource);

  @override
  Future<User> signInWithGoogle() async {
    final userModel = await dataSource.signInWithGoogle();
    return userModel.toDomain();
  }

  @override
  Future<void> signOut() async {
    await dataSource.signOut();
  }
}
