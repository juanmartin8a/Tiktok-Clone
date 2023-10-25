import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/notifications/notifications.dart';
import 'package:tiktokClone/screens/home/profile/profile_PV.dart';
import 'package:tiktokClone/screens/home/search/search.dart';
import 'package:tiktokClone/screens/home/upload/uplaod_vid.dart';
import '../../../services/database.dart';
import 'package:tiktokClone/screens/home/profile/my_followers.dart';
import 'package:tiktokClone/screens/home/profile/my_followings.dart';
import '../../../services/auth.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'edit_profile.dart';
import '../../../models/username.dart';
import 'package:video_player/video_player.dart';

class ProfilePosts extends StatefulWidget {
  final String videoUrl;
  final String videoId;
  final int index;
  final String myUid;
  ProfilePosts({this.index, this.videoUrl, this.videoId, this.myUid});
  @override
  _ProfilePostsState createState() => _ProfilePostsState();
}

class _ProfilePostsState extends State<ProfilePosts> {
  VideoPlayerController _controller;
  Future hasInitialized;

  Future<void> initialize() async {
    print(widget.index);
    final VideoPlayerController vController =
        VideoPlayerController.network(widget.videoUrl);
    vController.addListener(videoPlayerListener);
    //await vController.setLooping(true);
    hasInitialized = vController.initialize();
    final VideoPlayerController oldController = _controller;
    if (mounted) {
      print('HEY!!!!!');
      setState(() {
        _controller = vController;
      });
    }
    print('current post is ${widget.videoUrl}');
    await vController.pause();
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
    initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePageView(
                        currentIndex: widget.index,
                        myUid: widget.myUid,
                        videoUrl: widget.videoUrl,
                      )));
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                    width: _controller.value.size?.width ?? 0,
                    height: _controller.value.size?.height ?? 0,
                    child: VideoPlayer(_controller)))));
  }
}
