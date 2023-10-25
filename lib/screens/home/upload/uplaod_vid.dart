import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/notifications/notifications.dart';
import 'package:video_player/video_player.dart';
import '../../../services/database.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/profile/profile.dart';
import 'package:tiktokClone/screens/home/search/search.dart';

class VideoUpload extends StatefulWidget {
  @override
  _VideoUploadState createState() => _VideoUploadState();
}

class _VideoUploadState extends State<VideoUpload> {
  File _imageFile;
  DatabaseService databaseService = DatabaseService();
  final String id = DatabaseService().id;
  final _formKey = GlobalKey<FormState>();
  VideoPlayerController _controller;
  String cap = '';

  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://tiktokclone-d496a.appspot.com');
  StorageUploadTask _uploadTask;
  StorageTaskSnapshot _taskSnapshot;

  Future<void> _pickVideo(BuildContext context, ImageSource source) async {
    final selected = await ImagePicker().getVideo(source: source);

    setState(() {
      _imageFile = File(selected.path);
    });
  }

  _startUpload(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    if (_imageFile != null) {
      String filePath = 'videos/${DateTime.now()}.png';
      _uploadTask = _storage.ref().child(filePath).putFile(_imageFile);
      _taskSnapshot = await _uploadTask.onComplete;
      final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
      Map<String, dynamic> videoMap = {
        'profileImg': downloadUrl,
        'uid': user.uid,
        'cap': cap,
        'id': id,
      };
      DatabaseService(uid: id).uploadUserVideos(videoMap);
    }
  }

  Future hasInitialized;

  Future<void> initialize() async {
    if (_imageFile != null) {
      final VideoPlayerController vController =
          VideoPlayerController.file(_imageFile);
      vController.addListener(videoPlayerListener);
      await vController.setLooping(true);
      hasInitialized = vController.initialize();
      final VideoPlayerController oldController = _controller;
      if (mounted) {
        print('HEY!!!!!');
        setState(() {
          _controller = vController;
        });
      }
      await vController.play();
      await oldController?.dispose();
      print('controller is $_controller');
    } else {
      print('nothing');
    }
  }

  get videoPlayerListener => () {
        if (_controller != null && _controller.value.size != null) {
          // Refreshing the state to update video player with the correct ratio.
          if (mounted) setState(() {});
          _controller.removeListener(videoPlayerListener);
        }
      };

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          child: Container(
            color: Colors.grey[800],
            height: 0.2,
          ),
          preferredSize: Size.fromHeight(0.2),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[50],
        title: Text('Upload',
            style: TextStyle(
                color: Colors.black, fontSize: 18, letterSpacing: 0.68)),
        centerTitle: true,
      ),
      body: Stack(children: [
        Container(
            child: Column(children: [
          Container(
              child: Form(
                  key: _formKey,
                  child: TextFormField(
                    onChanged: (val) {
                      setState(() {
                        cap = val;
                      });
                    },
                  ))),
          _imageFile == null
              ? IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () {
                    _pickVideo(context, ImageSource.gallery);
                  })
              : Column(
                  children: [
                    FutureBuilder(
                      future: hasInitialized,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Container(
                            child: VideoPlayer(_controller),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    RaisedButton(
                        child: Text('Upload'),
                        onPressed: () {
                          _startUpload(context);
                        })
                  ],
                ),
        ])),
      ]),
      bottomNavigationBar: BottomAppBar(
          color: Colors.grey[50],
          child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey[800], width: 0.2))),
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 35,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: IconButton(
                              icon: Icon(Icons.home),
                              iconSize: 30,
                              padding: EdgeInsets.zero,
                              color: Colors.grey[600],
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForYou())),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Text('Home',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 11)))
                        ],
                      )),
                  Container(
                      height: 35,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: IconButton(
                                icon: Icon(Icons.search),
                                iconSize: 30,
                                padding: EdgeInsets.zero,
                                color: Colors.grey[600],
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchScreen())),
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Text('Discover',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 11)))
                          ])),
                  IconButton(
                      icon: Icon(Icons.add_box),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoUpload()))),
                  Container(
                      height: 35,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 5,
                            child: IconButton(
                              icon: Icon(Icons.inbox),
                              iconSize: 27,
                              padding: EdgeInsets.zero,
                              color: Colors.grey[700],
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Notifications())),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Text('Inbox',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 11))),
                        ],
                      )),
                  Container(
                      height: 35,
                      child: Column(children: [
                        Expanded(
                            flex: 5,
                            child: IconButton(
                              icon: Icon(Icons.person),
                              iconSize: 30,
                              color: Colors.black,
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Profile())),
                            )),
                        Expanded(
                            flex: 2,
                            child: Text('Me',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 11)))
                      ]))
                ],
              ))),
    );
  }
}
