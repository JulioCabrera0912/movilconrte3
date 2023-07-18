import '../entities/message.dart';

abstract class MessageRepository {
  Future<void> saveMessage(Message message);
  Future<List<Message>> getMessages();
}
