import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_auth/features/chats/presentation/pages/chat_screen.dart';
import 'package:app_auth/usecase_config.dart';
import 'package:app_auth/features/chats/data/datasources/message_datasource.dart';
import 'package:app_auth/features/user/presentation/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:app_auth/features/user/domain/usecases/sign_in_usecase.dart';
import 'package:app_auth/features/user/data/repositories/auth_repository_imp.dart';
import 'package:app_auth/features/user/data/datasources/firebase_auth_datasource.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<SignInWithGoogleUseCase>(
          create: (context) => SignInWithGoogleUseCase(
            AuthRepositoryImp(
              FirebaseAuthDataSource(
                firebaseAuth: FirebaseAuth.instance,
                googleSignIn: GoogleSignIn(),
              ),
            ),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseMessageDataSource = FirebaseMessageDataSource(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
      auth: FirebaseAuth.instance,
    );
    final useCaseConfig = UsecaseConfig(firebaseMessageDataSource);

    return MaterialApp(
      title: 'Mi aplicación',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/chat': (context) => ChatScreen(useCaseConfig: useCaseConfig)
      },
    );
  }
}
