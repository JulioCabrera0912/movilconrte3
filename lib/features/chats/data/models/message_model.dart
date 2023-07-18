import 'dart:io';
import 'package:app_auth/features/chats/domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required final String userId,
    final String? text,
    String? latitude,
    String? longitude,
    File? imageUrl,
    File? videoUrl,
    File? audioUrl,
    File? pdfUrl,
    required final String userName,
    required final DateTime timestamp,
  }) : super(
          userId: userId,
          text: text,
          latitude: latitude,
          longitude: longitude,
          imageUrl: imageUrl,
          videoUrl: videoUrl,
          audioUrl: audioUrl,
          pdfUrl: pdfUrl,
          userName: userName,
          timestamp: timestamp,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      userId: json['userId'],
      text: json['text'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      audioUrl: json['audioUrl'],
      pdfUrl: json['pdfUrl'],
      userName: json['userName'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'text': text,
      'userName': userName,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  MessageModel copyWith({
    String? userId,
    String? text,
    String? latitude,
    String? longitude,
    File? imageUrl,
    File? videoUrl,
    File? audioUrl,
    File? pdfUrl,
    String? userName,
    DateTime? timestamp,
  }) {
    return MessageModel(
      userId: userId ?? this.userId,
      text: text ?? this.text,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      userName: userName ?? this.userName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      userId: message.userId,
      text: message.text,
      latitude: message.latitude,
      longitude: message.longitude,
      imageUrl: message.imageUrl,
      videoUrl: message.videoUrl,
      audioUrl: message.audioUrl,
      pdfUrl: message.pdfUrl,
      userName: message.userName,
      timestamp: message.timestamp,
    );
  }
}
