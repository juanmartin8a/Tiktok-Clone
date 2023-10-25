import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/profile/profile.dart';
import 'package:tiktokClone/screens/home/profile/profiles.dart';
import 'package:tiktokClone/screens/home/search/search.dart';
import 'package:tiktokClone/screens/home/upload/uplaod_vid.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/username.dart';
import 'package:video_player/video_player.dart';
import 'comment_form.dart';

class MainActions extends StatefulWidget {
  final String profileImg;
  final String id;
  final String uid;
  final bool userHasLiked;
  final Function likedState;
  MainActions(
      {this.profileImg, this.id, this.userHasLiked, this.likedState, this.uid});

  @override
  _MainActionsState createState() => _MainActionsState();
}

class _MainActionsState extends State<MainActions> {
  bool userHasLiked = false;
  int likeCount = 0;
  int commentsCount = 0;

  commentBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Comments(
            id: widget.id,
            uid: widget.uid,
          );
        });
  }

  @override
  void initState() {
    getLikedState(context);
    getLikesCount();
    getCommentsCount();
    super.initState();
  }

  getLikedState(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    print(widget.id);
    await DatabaseService(uid: widget.id).getUserLikes(user.uid).then((value) {
      print(value);
      setState(() {
        userHasLiked = value;
      });
    });
  }

  getLikesCount() async {
    await DatabaseService(uid: widget.id).countLikeDocuments().then((value) {
      print(value);
      setState(() {
        likeCount = value;
      });
    });
  }

  getCommentsCount() async {
    await DatabaseService(uid: widget.id).countCommentDocuments().then((value) {
      print(value);
      setState(() {
        commentsCount = value;
      });
    });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    print('profile image is ${widget.profileImg}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            color: Colors.transparent,
            child: Column(children: [
              Container(
                  child: userHasLiked
                      ? IconButton(
                          padding: EdgeInsets.all(0.0),
                          icon: Icon(Icons.favorite,
                              color: Colors.red[700], size: 50),
                          onPressed: () {
                            DatabaseService(uid: widget.id)
                                .deleteUserLikes(user.uid);
                            getLikedState(context);
                            getLikesCount();
                          })
                      : StreamBuilder<DocumentSnapshot>(
                          stream:
                              DatabaseService(uid: user.uid).getUserProfile(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> currentUserdocs =
                                  snapshot.data.data();
                              return /*StreamBuilder<UserData>(
                                stream: DatabaseService(uid: user.uid).userData,
                                builder: (context, snap) {
                                  if (snap.hasData) {*/
                                  IconButton(
                                      padding: EdgeInsets.all(0.0),
                                      icon: Icon(Icons.favorite,
                                          color: Colors.grey[300], size: 50),
                                      onPressed: () {
                                        Map<String, dynamic> likeMap = {
                                          'likeUserUid': user.uid,
                                          'likedUserVideo': widget.uid,
                                          'likeUserName':
                                              currentUserdocs['name'],
                                          'time': DateTime.now()
                                              .millisecondsSinceEpoch,
                                        };
                                        DatabaseService(uid: widget.id)
                                            .likeVideo(likeMap, user.uid);
                                        getLikedState(context);
                                        getLikesCount();
                                      });
                              //}
                              //});

                            } else {
                              return IconButton(
                                  padding: EdgeInsets.all(0.0),
                                  icon: Icon(Icons.favorite,
                                      color: Colors.grey[300], size: 50),
                                  onPressed: () {
                                    getLikedState(context);
                                    getLikesCount();
                                  });
                            }
                          })),
              Container(
                  child: Text('$likeCount',
                      style: TextStyle(
                        color: Colors.grey[50],
                      )))
            ])),
        Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                    child: IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(Icons.comment,
                            color: Colors.grey[300], size: 40),
                        onPressed: () {
                          commentBottomSheet(context);
                          getCommentsCount();
                        })),
                Container(
                    child: Text('$commentsCount',
                        style: TextStyle(
                          color: Colors.grey[50],
                        )))
              ],
            )),
        Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            color: Colors.transparent,
            child: IconButton(
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.subdirectory_arrow_right,
                    color: Colors.grey[300], size: 40),
                onPressed: () {}))
      ],
    );
  }
}
