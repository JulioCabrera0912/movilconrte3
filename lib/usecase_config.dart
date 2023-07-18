import 'package:app_auth/features/chats/data/datasources/message_datasource.dart';
import 'package:app_auth/features/chats/data/repositories/message_repository_imp.dart';
import 'package:app_auth/features/chats/domain/usecases/get_messages_usecase.dart';
import 'package:app_auth/features/chats/domain/usecases/save_message_usecase.dart';
import 'package:app_auth/features/user/domain/usecases/sign_in_usecase.dart';
import 'package:app_auth/features/user/data/datasources/firebase_auth_datasource.dart';
import 'package:app_auth/features/user/data/repositories/auth_repository_imp.dart';

class UsecaseConfig {
  GetMessagesUseCase? getMessagesUseCase;
  SaveMessageUseCase? saveMessageUseCase;
  MessageRepositoryImp? messageRepositoryImp;
  FirebaseMessageDataSource firebaseMessageDataSource;

  UsecaseConfig(this.firebaseMessageDataSource) {
    messageRepositoryImp = MessageRepositoryImp(firebaseMessageDataSource);
    getMessagesUseCase = GetMessagesUseCase(messageRepositoryImp!);
    saveMessageUseCase = SaveMessageUseCase(messageRepositoryImp!);
  }
}
