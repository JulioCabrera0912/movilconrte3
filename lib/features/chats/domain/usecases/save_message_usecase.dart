import '../entities/message.dart';
import '../repositories/message_repository.dart';

class SaveMessageUseCase {
  final MessageRepository repository;

  SaveMessageUseCase(this.repository);

  Future<void> call(Message message) async {
    await repository.saveMessage(message);
  }
}
