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

class CommentsChild extends StatefulWidget {
  final String userUid;
  final String comment;
  final String commentId;
  final String videoId;
  final String profileImg;
  final String name;
  final int length;
  CommentsChild(
      {this.userUid,
      this.comment,
      this.videoId,
      this.name,
      this.length,
      this.profileImg,
      this.commentId});
  @override
  _CommentsChildState createState() => _CommentsChildState();
}

class _CommentsChildState extends State<CommentsChild> {
  bool userHasLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    getLikedState(context);
    getLikesCount();
    super.initState();
  }

  getLikedState(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(uid: widget.videoId, docId: widget.commentId)
        .getLikeComment(user.uid)
        .then((value) {
      print(value);
      setState(() {
        userHasLiked = value;
      });
    });
  }

  getLikesCount() async {
    await DatabaseService(uid: widget.videoId, docId: widget.commentId)
        .countLikeComment()
        .then((value) {
      print(value);
      setState(() {
        likeCount = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return GestureDetector(
        onLongPress: () {
          DatabaseService(uid: widget.videoId, docId: widget.commentId)
              .deleteComment();
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      Row(
                        children: [
                          Container(
                              child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(widget.profileImg),
                            backgroundColor: Colors.grey[300],
                          )),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(widget.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ))),
                                  Container(
                                      child: Text(widget.comment,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          )))
                                ]),
                          ),
                        ],
                      ),
                      Container(
                          height: 40,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    height: 22,
                                    padding: EdgeInsets.all(0.0),
                                    child: userHasLiked
                                        ? IconButton(
                                            padding: EdgeInsets.all(0.0),
                                            icon: Icon(Icons.favorite,
                                                color: Colors.red[700],
                                                size: 18),
                                            onPressed: () {
                                              DatabaseService(
                                                      uid: widget.videoId,
                                                      docId: widget.commentId)
                                                  .deleteLikeComment(user.uid);
                                              getLikedState(context);
                                              getLikesCount();
                                            })
                                        : IconButton(
                                            padding: EdgeInsets.all(0.0),
                                            icon: Icon(Icons.favorite_border,
                                                color: Colors.black, size: 18),
                                            onPressed: () {
                                              Map<String, dynamic>
                                                  commentLikeMap = {
                                                'like user uid': user.uid,
                                              };
                                              DatabaseService(
                                                      uid: widget.videoId,
                                                      docId: widget.commentId)
                                                  .likeComment(
                                                      commentLikeMap, user.uid);
                                              getLikedState(context);
                                              getLikesCount();
                                            })),
                                Container(
                                    height: 14,
                                    child: Text('$likeCount',
                                        style: userHasLiked
                                            ? TextStyle(
                                                color: Colors.red[700],
                                                fontSize: 13,
                                              )
                                            : TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                              )))
                              ])),
                    ]))
              ],
            )));
  }
}
