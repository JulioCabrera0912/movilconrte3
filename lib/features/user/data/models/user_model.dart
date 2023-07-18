import 'package:app_auth/features/user/domain/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel {
  final String name;
  final String email;
  final String imageUrl;

  UserModel({
    required this.name,
    required this.email,
    required this.imageUrl,
  });

  User toDomain() {
    return User(
      name: name,
      email: email,
      imageUrl: imageUrl,
    );
  }

  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(
      name: user.displayName ?? '',
      email: user.email ?? '',
      imageUrl: user.photoURL ?? '',
    );
  }
}
