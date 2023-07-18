import 'dart:io';
import 'package:flutter/material.dart';

class Message {
  final String userId;
  final String? text;
  String? latitude;
  String? longitude;
  File? imageUrl;
  File? videoUrl;
  File? audioUrl;
  File? pdfUrl;
  final DateTime timestamp;
  final String userName;

  Message({
    required this.userId,
    this.text,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.pdfUrl,
    required this.timestamp,
    required this.userName,
  });
}
