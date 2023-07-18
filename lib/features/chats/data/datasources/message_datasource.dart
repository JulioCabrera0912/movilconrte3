import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_auth/features/chats/domain/entities/message.dart';
import '../models/message_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

abstract class MessageDataSource {
  Future<void> saveMessage(MessageModel message);
  Future<List<MessageModel>> getMessages();
}

class FirebaseMessageDataSource implements MessageDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  FirebaseMessageDataSource({
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  @override
  Future<void> saveMessage(MessageModel message) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not found');
    }

    final messageRef = firestore.collection('messages').doc();
    final messageWithId = message.copyWith(
      userId: user.uid,
      text: null,
      latitude: null,
      longitude: null,
      imageUrl: null,
      videoUrl: null,
      audioUrl: null,
      pdfUrl: null,
    );

    await messageRef.set(messageWithId.toJson());

    if (message.text != null && message.text!.length >= 1) {
      await messageRef.update({'text': message.text});
    }

    if (message.imageUrl != null) {
      final imageRef = storage.ref().child('images/${messageRef.id}');
      await imageRef.putFile(message.imageUrl!);
      final imageUrl = await imageRef.getDownloadURL();
      await messageRef.update({'imageUrl': imageUrl});
    }

    if (message.videoUrl != null) {
      final videoRef = storage.ref().child('videos/${messageRef.id}');
      await videoRef.putFile(message.videoUrl!);
      final videoUrl = await videoRef.getDownloadURL();
      await messageRef.update({'videoUrl': videoUrl});
    }

    if (message.audioUrl != null) {
      final audioRef = storage.ref().child('audios/${messageRef.id}');
      await audioRef.putFile(message.audioUrl!);
      final audioUrl = await audioRef.getDownloadURL();
      await messageRef.update({'audioUrl': audioUrl});
    }

    if (message.pdfUrl != null) {
      final pdfRef = storage.ref().child('pdfs/${messageRef.id}');
      await pdfRef.putFile(message.pdfUrl!);
      final pdfUrl = await pdfRef.getDownloadURL();
      await messageRef.update({'pdfUrl': pdfUrl});
    }

    if (message.latitude != null && message.longitude != null) {
      await messageRef.update({
        'latitude': message.latitude,
        'longitude': message.longitude,
      });
    }
  }

  @override
  Future<List<MessageModel>> getMessages() async {
    final messagesQuery =
        await firestore.collection('messages').orderBy('timestamp').get();
    final List<MessageModel> messages = [];

    for (final messageDoc in messagesQuery.docs) {
      final messageData = messageDoc.data();
      final messageModel = MessageModel(
        userId: messageData['userId'],
        text: messageData['text'],
        latitude: messageData['latitude'],
        longitude: messageData['longitude'],
        imageUrl: null,
        videoUrl: null,
        audioUrl: null,
        pdfUrl: null,
        userName: messageData['userName'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            messageData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      );

      if (messageData.containsKey('imageUrl')) {
        final imageUrl = messageData['imageUrl'];
        final imageFile = await _downloadFile(imageUrl);
        messageModel.imageUrl = imageFile;
      }

      if (messageData.containsKey('videoUrl')) {
        final videoUrl = messageData['videoUrl'];
        final videoFile = await _downloadFile(videoUrl);
        messageModel.videoUrl = videoFile;
      }

      if (messageData.containsKey('audioUrl')) {
        final audioUrl = messageData['audioUrl'];
        final audioFile = await _downloadFile(audioUrl);
        messageModel.audioUrl = audioFile;
      }

      if (messageData.containsKey('pdfUrl')) {
        final pdfUrl = messageData['pdfUrl'];
        final pdfFile = await _downloadFile(pdfUrl);
        messageModel.pdfUrl = pdfFile;
      }

      messages.add(messageModel);
    }

    return messages;
  }

  Future<File> _downloadFile(String url) async {
    final uuid = Uuid();
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${uuid.v4()}';
    final file = File(filePath);
    final response = await storage.refFromURL(url).writeToFile(file);
    if (response.state == TaskState.success) {
      return file;
    } else {
      throw Exception('Error');
    }
  }
}
