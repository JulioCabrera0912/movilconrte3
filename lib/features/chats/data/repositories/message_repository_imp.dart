import 'package:app_auth/features/chats/data/datasources/message_datasource.dart';
import 'package:app_auth/features/chats/domain/entities/message.dart';
import 'package:app_auth/features/chats/domain/repositories/message_repository.dart';
import '../models/message_model.dart';

class MessageRepositoryImp implements MessageRepository {
  final MessageDataSource dataSource;

  MessageRepositoryImp(this.dataSource);

  @override
  Future<void> saveMessage(Message message) async {
    final messageModel = MessageModel.fromEntity(message);
    await dataSource.saveMessage(messageModel);
  }

  @override
  Future<List<MessageModel>> getMessages() async {
    return dataSource.getMessages();
  }
}
