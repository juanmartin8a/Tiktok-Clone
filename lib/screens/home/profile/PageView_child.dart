import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/comment_form.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/main/main_actions.dart';
import 'package:tiktokClone/screens/home/notifications/notifications.dart';
import 'package:tiktokClone/screens/home/profile/profile.dart';
import 'package:tiktokClone/screens/home/profile/profiles.dart';
import 'package:tiktokClone/screens/home/search/search.dart';
import 'package:tiktokClone/screens/home/upload/uplaod_vid.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/username.dart';
import 'package:video_player/video_player.dart';

class ProfilePVChild extends StatefulWidget {
  final int snapLength;
  final int index;
  final String postsList;
  final String uid;
  final String cap;
  final String id;
  ProfilePVChild(
      {this.snapLength,
      this.postsList,
      this.index,
      this.uid,
      this.cap,
      this.id});
  @override
  _ProfilePVChildState createState() => _ProfilePVChildState();
}

class _ProfilePVChildState extends State<ProfilePVChild> {
  VideoPlayerController _controller;
  final PageController ctrl = PageController();
  List<Map<String, String>> postsList = [];
  Future hasInitialized;
  int commentsCount = 0;

  commentBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Comments(
            id: widget.id,
          );
        });
  }

  Future<void> initialize() async {
    print(widget.index);
    final VideoPlayerController vController =
        VideoPlayerController.network(widget.postsList);
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
    print('current post is ${widget.postsList}');
    await vController.play();
    await oldController?.dispose();
    print('controller is $_controller');
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
    getCommentsCount();
    initialize();
  }

  getCommentsCount() async {
    await DatabaseService(uid: widget.id).countCommentDocuments().then((value) {
      print(value);
      setState(() {
        commentsCount = value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return FutureBuilder(
        future: hasInitialized,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<DocumentSnapshot>(
                    stream: DatabaseService(uid: widget.uid).getUserProfile(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                      if (snap.hasData) {
                        Map<String, dynamic> snapMap = snap.data.data();
                        return Container(
                          height: 500,
                          child: _controller.value.initialized
                              ? Container(
                                  color: Colors.red,
                                  child: Stack(children: [
                                    Container(
                                      child: VideoPlayer(_controller),
                                    ),
                                    Container(
                                        color: Colors.transparent,
                                        child: _controller.value.isPlaying
                                            ? Container(
                                                child: InkWell(
                                                    onTap: () =>
                                                        _controller.pause(),
                                                    child: Container()))
                                            : Container(
                                                child: InkWell(
                                                    onTap: () =>
                                                        _controller.play(),
                                                    child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Container(
                                                            child: Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                size: 80,
                                                                color: Colors
                                                                    .white54)))))),
                                    Container(
                                      child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.70,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.17,
                                            margin: EdgeInsets.only(
                                              bottom: 50,
                                              left: 5,
                                              right: 5,
                                            ),
                                            padding: EdgeInsets.all(10),
                                            color: Colors.transparent,
                                            child: Container(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    color: Colors.transparent,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => Profiles(
                                                                      userUID:
                                                                          snapMap[
                                                                              'uid'],
                                                                      currentUserUID:
                                                                          user.uid)));
                                                        },
                                                        child: Text(
                                                          '@${snapMap['name']}',
                                                          style: TextStyle(
                                                            color:
                                                                Colors.grey[50],
                                                            letterSpacing: 0.70,
                                                            fontSize: 16,
                                                          ),
                                                        ))),
                                                Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10),
                                                    color: Colors.transparent,
                                                    child: Text(
                                                      widget.cap,
                                                      style: TextStyle(
                                                        color: Colors.grey[300],
                                                        letterSpacing: 0.65,
                                                        fontSize: 14,
                                                      ),
                                                    )),
                                              ],
                                            )),
                                          )),
                                    ),
                                    Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                            margin: EdgeInsets.only(
                                              bottom: 50,
                                              left: 5,
                                              right: 5,
                                            ),
                                            padding: EdgeInsets.all(10),
                                            color: Colors.transparent,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.20,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.45,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12),
                                                      color: Colors.transparent,
                                                      child: CircleAvatar(
                                                        radius: 25,
                                                        backgroundImage:
                                                            NetworkImage(snapMap[
                                                                'profileImg']),
                                                        backgroundColor:
                                                            Colors.grey[300],
                                                      )),
                                                  MainActions(
                                                    profileImg:
                                                        snapMap['profileImg'],
                                                    id: widget.id,
                                                  )
                                                ]))),
                                    Align(
                                        alignment: Alignment.bottomCenter,
                                        child: GestureDetector(
                                            onTap: () {
                                              commentBottomSheet(context);
                                              getCommentsCount();
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        top: BorderSide(
                                                            color: Colors.grey,
                                                            width: 0.2))),
                                                height: 45,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                          child: Text(
                                                              'Add comment...',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                          .grey[
                                                                      500]))),
                                                      Container(
                                                          child: Icon(
                                                              Icons.send,
                                                              color: Colors
                                                                  .grey[500]))
                                                    ]))))
                                  ]))
                              : Container(
                                  color: Colors.red,
                                  child: Text('didnt initialize')),
                        );
                      } else {
                        return Container();
                      }
                    }));
          } else {
            return Container();
          }
        });
  }
}
