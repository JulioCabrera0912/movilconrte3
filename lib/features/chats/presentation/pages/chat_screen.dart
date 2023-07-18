import 'dart:io';
import 'package:app_auth/features/chats/domain/entities/message.dart';
import 'package:app_auth/features/chats/domain/usecases/save_message_usecase.dart';
import 'package:app_auth/features/chats/domain/usecases/get_messages_usecase.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_auth/features/user/domain/usecases/sign_in_usecase.dart';
import 'package:provider/provider.dart';
import 'package:app_auth/usecase_config.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import './pdf_view.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ChatScreen extends StatefulWidget {
  final UsecaseConfig useCaseConfig;

  ChatScreen({required this.useCaseConfig});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final String? userName = FirebaseAuth.instance.currentUser!.displayName;

  final _messageController = TextEditingController();
  File? _selectedImage;
  File? _selectedVideo;
  File? _selectedAudio;
  File? _selectedPdf;
  String? _latitude;
  String? _longitude;

  Future<void> _sendMessage() async {
    final message = Message(
      userId: currentUser!.uid,
      text: _messageController.text,
      imageUrl: _selectedImage,
      videoUrl: _selectedVideo,
      audioUrl: _selectedAudio,
      pdfUrl: _selectedPdf,
      latitude: _latitude,
      longitude: _longitude,
      userName: userName!,
      timestamp: DateTime.now(),
    );
    await widget.useCaseConfig.saveMessageUseCase!(message);
    _messageController.clear();
    setState(() {
      _selectedImage = null;
      _selectedVideo = null;
      _selectedAudio = null;
      _selectedPdf = null;
      _latitude = null;
    });
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      _selectedAudio = File(result.files.single.path!);
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      _selectedImage = File(result.files.single.path!);
    }
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      _selectedVideo = File(result.files.single.path!);
    }
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      _selectedPdf = File(result.files.single.path!);
    }
  }

  Future<void> _getUbication() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      _latitude = _locationData.latitude.toString();
      _longitude = _locationData.longitude.toString();
    });
  }

  Widget _buildMessageBubble(Message message) {
    final isCurrentUser = message.userName == userName;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(isCurrentUser ? 'Yo' : message.userName!),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isCurrentUser ? Color(0xFFE0E0E0) : Colors.black,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.text != null)
                  Text(message.text!,
                      style: TextStyle(
                          color: isCurrentUser ? Colors.black : Colors.white,
                          fontSize: 16.0)),
                if (message.imageUrl != null)
                  Container(
                    height: 180,
                    width: 160,
                    child: Image.file(message.imageUrl!),
                  ),
                if (message.videoUrl != null)
                  VideoPlayerWidget(message.videoUrl!),
                if (message.audioUrl != null)
                  AudioPlayerWidget(message.audioUrl!),
                if (message.pdfUrl != null)
                  // redireccionar a la pagina de pdf
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfView(path: message.pdfUrl!),
                        ),
                      );
                    },
                    child: Container(
                      height: 90,
                      width: 70,
                      child: Image.asset('assets/img/pdf.png'),
                    ),
                  ),
                if (message.latitude != null && message.longitude != null)
                  Container(
                    height: 200,
                    width: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          double.parse(message.latitude!),
                          double.parse(message.longitude!),
                        ),
                        zoom: 14.0,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('my ubication'),
                          position: LatLng(
                            double.parse(message.latitude!),
                            double.parse(message.longitude!),
                          ),
                        ),
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 55,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text('Chat IS',
            style: TextStyle(fontSize: 18, color: Colors.black)),
        centerTitle: true,
        // linea de abajo
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey,
            height: 1,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream:
                  widget.useCaseConfig.getMessagesUseCase!.call().asStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(message);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const Text('Loading...');
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3636),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.photo),
                              title: Text('Choose Image'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _pickImage();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.videocam),
                              title: Text('Choose Video'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _pickVideo();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.audiotrack),
                              title: Text('Choose Audio'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _pickAudio();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.picture_as_pdf),
                              title: Text('Choose PDF'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _pickPdf();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.location_on),
                              title: Text('Choose Location'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _getUbication();
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;

  VideoPlayerWidget(this.videoFile);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_videoPlayerController.value.isPlaying) {
            _videoPlayerController.pause();
          } else {
            _videoPlayerController.play();
          }
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          width: 160,
          height: 180,
          child: _videoPlayerController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                )
              : Container(),
        ),
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final File audioFile;

  AudioPlayerWidget(this.audioFile);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_isPlaying) {
          await _audioPlayer.pause();
          setState(() {
            _isPlaying = false;
          });
        } else {
          await _audioPlayer.play(UrlSource(
            widget.audioFile.path,
          ));
          setState(() {
            _isPlaying = true;
          });
        }
      },
      child: Container(
        width: 190,
        height: 50,
        decoration: BoxDecoration(
          color: _isPlaying ? Colors.green : Colors.black,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Text(
              _isPlaying ? 'Stop' : 'Play',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
