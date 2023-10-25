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

class MessageTile extends StatefulWidget {
  final String message;
  final bool isSendByMe;
  final String myProPic;
  final String proPic;
  final String chatRoomId;
  final String messageId;
  final String userUids;
  MessageTile(
      {this.message,
      this.isSendByMe,
      this.myProPic,
      this.proPic,
      this.chatRoomId,
      this.messageId,
      this.userUids});
  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool userHasLiked = false;
  bool videoLiked = false;
  int likeCount = 0;
  QuerySnapshot messageLikesStream;

  @override
  void initState() {
    getLikedState(context);
    getLikesCount();
    getChatRooms();
    super.initState();
  }

  getChatRooms() async {
    DatabaseService(uid: widget.chatRoomId, docId: widget.messageId)
        .getMessageLikes()
        .then((snapshots) {
      setState(() {
        messageLikesStream = snapshots;
      });
    });
  }

  getLikedState(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(uid: widget.chatRoomId, docId: widget.messageId)
        .getLikeMessage(user.uid)
        .then((value) {
      print(value);
      setState(() {
        userHasLiked = value;
      });
    });
  }

  getLikesCount() async {
    await DatabaseService(uid: widget.chatRoomId, docId: widget.messageId)
        .countLikeMessage()
        .then((value) {
      print(value);
      setState(() {
        likeCount = value;
      });
    });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context, listen: false);
    print('my profile img url is ${widget.myProPic}');
    return likeCount < 0 || likeCount == 0
        ? GestureDetector(
            onDoubleTap: () {
              Map<String, dynamic> likeMessageMap = {
                'liked user uid': user.uid,
              };
              DatabaseService(uid: widget.chatRoomId, docId: widget.messageId)
                  .likeMessage(likeMessageMap, user.uid);
              getChatRooms();
              getLikesCount();
              getLikedState(context);
            },
            onLongPress: () {
              DatabaseService(uid: widget.chatRoomId, docId: widget.messageId)
                  .deleteConversationMessage();
            },
            child: Container(
                padding: EdgeInsets.only(
                    top: 12,
                    bottom: 4,
                    left: widget.isSendByMe ? 0 : 24,
                    right: widget.isSendByMe ? 24 : 0),
                alignment: widget.isSendByMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                margin: EdgeInsets.only(
                  top: 8,
                ),
                width: MediaQuery.of(context).size.width,
                child: widget.isSendByMe
                    ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.7, color: Colors.grey[200]),
                                color: Colors.grey[200],
                                /*LinearGradient(
                    colors: widget.isSendByMe
                        ? [
                            const Color(0xff007EF4),
                            const Color(0xff2A75BC),
                          ]
                        : [const Color(0xff007EF4), const Color(0xff2A75BC)]),*/
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(9),
                                  topRight: Radius.circular(9),
                                  bottomRight: Radius.circular(9),
                                  bottomLeft: Radius.circular(9),
                                )),
                            child: Text(widget.message,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  letterSpacing: 0.57,
                                ))),
                        Container(
                            margin: EdgeInsets.only(left: 6),
                            child: CircleAvatar(
                                radius: 15,
                                backgroundImage: NetworkImage(widget.myProPic)))
                      ])
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            Container(
                                margin: EdgeInsets.only(right: 6),
                                child: CircleAvatar(
                                    radius: 15,
                                    backgroundImage:
                                        NetworkImage(widget.proPic))),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.2, color: Colors.grey[200]),
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(9),
                                      topRight: Radius.circular(9),
                                      bottomRight: Radius.circular(9),
                                      bottomLeft: Radius.circular(9),
                                    )),
                                child: Text(widget.message,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 0.57,
                                    ))),
                          ])))
        : Column(children: [
            GestureDetector(
                onDoubleTap: () {
                  Map<String, dynamic> likeMessageMap = {
                    'liked user uid': user.uid,
                  };
                  DatabaseService(
                          uid: widget.chatRoomId, docId: widget.messageId)
                      .likeMessage(likeMessageMap, user.uid);
                  getChatRooms();
                  getLikesCount();
                  getLikedState(context);
                },
                onLongPress: () {
                  DatabaseService(
                          uid: widget.chatRoomId, docId: widget.messageId)
                      .deleteConversationMessage();
                },
                child: Container(
                    padding: EdgeInsets.only(
                        top: 12,
                        bottom: 4,
                        left: widget.isSendByMe ? 0 : 24,
                        right: widget.isSendByMe ? 24 : 0),
                    alignment: widget.isSendByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    margin: EdgeInsets.only(
                      top: 8,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: widget.isSendByMe
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0.7,
                                                  color: Colors.grey[200]),
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(9),
                                                topRight: Radius.circular(9),
                                                bottomRight: Radius.circular(9),
                                                bottomLeft: Radius.circular(9),
                                              )),
                                          child: Text(widget.message,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                letterSpacing: 0.57,
                                              ))),
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                    height: 17,
                                                    width: 17,
                                                    padding: EdgeInsets.zero,
                                                    child: userHasLiked
                                                        ? IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            onPressed: () {
                                                              DatabaseService(
                                                                      uid: widget
                                                                          .chatRoomId,
                                                                      docId: widget
                                                                          .messageId)
                                                                  .deleteLikeMessage(
                                                                      user.uid);
                                                              getChatRooms();
                                                              getLikesCount();
                                                              getLikedState(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                                Icons.favorite,
                                                                color: Colors
                                                                    .red[700],
                                                                size: 16))
                                                        : IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            onPressed: () {
                                                              Map<String,
                                                                      dynamic>
                                                                  likeMessageMap =
                                                                  {
                                                                'liked user uid':
                                                                    user.uid,
                                                              };
                                                              DatabaseService(
                                                                      uid: widget
                                                                          .chatRoomId,
                                                                      docId: widget
                                                                          .messageId)
                                                                  .likeMessage(
                                                                      likeMessageMap,
                                                                      user.uid);
                                                              getChatRooms();
                                                              getLikesCount();
                                                              getLikedState(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                                Icons.favorite,
                                                                color: Colors
                                                                    .red[700],
                                                                size: 14))),
                                                Container(
                                                    height: 20,
                                                    //width: 20,
                                                    child: FutureBuilder<
                                                            dynamic>(
                                                        future: DatabaseService(
                                                                uid: widget
                                                                    .chatRoomId,
                                                                docId: widget
                                                                    .messageId)
                                                            .getMessageLikes(),
                                                        builder: (context,
                                                            AsyncSnapshot<
                                                                    dynamic>
                                                                snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .done) {
                                                            print(
                                                                'we have made it till streambuilder');
                                                            List<
                                                                    Map<String,
                                                                        String>>
                                                                messageLikeList =
                                                                [];
                                                            for (int i = 0;
                                                                i <
                                                                    snapshot
                                                                        .data
                                                                        .docs
                                                                        .length;
                                                                i++) {
                                                              Map<String,
                                                                      String>
                                                                  messageLikeMap =
                                                                  {
                                                                'likedUserUid': snapshot
                                                                        .data
                                                                        .docs[i]
                                                                        .data()[
                                                                    'liked user uid']
                                                              };
                                                              messageLikeList.add(
                                                                  messageLikeMap);
                                                            }
                                                            return ListView
                                                                .builder(
                                                                    scrollDirection:
                                                                        Axis
                                                                            .horizontal,
                                                                    shrinkWrap:
                                                                        true,
                                                                    itemCount:
                                                                        messageLikeList
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      print(
                                                                          'we have made it till listView ${messageLikeList.length}');
                                                                      print(
                                                                          'likedUserUid is $messageLikeList');
                                                                      return Container(
                                                                          height:
                                                                              20,
                                                                          /*width:
                                                                              20,*/
                                                                          child: StreamBuilder<DocumentSnapshot>(
                                                                              stream: DatabaseService(uid: messageLikeList[index]['likedUserUid']).getUserProfile(),
                                                                              builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                                                                                if (snap.hasData) {
                                                                                  Map<String, dynamic> documentFields = snap.data.data();
                                                                                  print('j profileImgs are ${documentFields['profileImg']}');
                                                                                  return Row(children: [
                                                                                    Container(child: CircleAvatar(radius: 10, backgroundImage: NetworkImage(documentFields['profileImg']), backgroundColor: Colors.grey))
                                                                                  ]);
                                                                                } else {
                                                                                  //print('returning')
                                                                                  return Container();
                                                                                }
                                                                              }));
                                                                    });
                                                          } else {
                                                            return Container();
                                                          }
                                                        }))
                                              ]))
                                    ]),
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                        margin: EdgeInsets.only(left: 6),
                                        child: CircleAvatar(
                                            radius: 15,
                                            backgroundImage:
                                                NetworkImage(widget.myProPic))))
                              ])
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                                Container(
                                    margin: EdgeInsets.only(right: 6),
                                    child: CircleAvatar(
                                        radius: 15,
                                        backgroundImage:
                                            NetworkImage(widget.proPic))),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0.7,
                                                  color: Colors.grey[200]),
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(9),
                                                topRight: Radius.circular(9),
                                                bottomRight: Radius.circular(9),
                                                bottomLeft: Radius.circular(9),
                                              )),
                                          child: Text(widget.message,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                letterSpacing: 0.57,
                                              ))),
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                    height: 17,
                                                    width: 17,
                                                    padding: EdgeInsets.zero,
                                                    child: userHasLiked
                                                        ? IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            onPressed: () {
                                                              DatabaseService(
                                                                      uid: widget
                                                                          .chatRoomId,
                                                                      docId: widget
                                                                          .messageId)
                                                                  .deleteLikeMessage(
                                                                      user.uid);
                                                              getChatRooms();
                                                              getLikesCount();
                                                              getLikedState(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                                Icons.favorite,
                                                                color: Colors
                                                                    .red[700],
                                                                size: 16))
                                                        : IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            onPressed: () {
                                                              Map<String,
                                                                      dynamic>
                                                                  likeMessageMap =
                                                                  {
                                                                'liked user uid':
                                                                    user.uid,
                                                              };
                                                              DatabaseService(
                                                                      uid: widget
                                                                          .chatRoomId,
                                                                      docId: widget
                                                                          .messageId)
                                                                  .likeMessage(
                                                                      likeMessageMap,
                                                                      user.uid);
                                                              getChatRooms();
                                                              getLikesCount();
                                                              getLikedState(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                                Icons.favorite,
                                                                color: Colors
                                                                    .red[700],
                                                                size: 14))),
                                                Container(
                                                    height: 20,
                                                    //width: 20,
                                                    child: FutureBuilder<
                                                            dynamic>(
                                                        future: DatabaseService(
                                                                uid: widget
                                                                    .chatRoomId,
                                                                docId: widget
                                                                    .messageId)
                                                            .getMessageLikes(),
                                                        builder: (context,
                                                            AsyncSnapshot<
                                                                    dynamic>
                                                                snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .done) {
                                                            print(
                                                                'we have made it till streambuilder');
                                                            List<
                                                                    Map<String,
                                                                        String>>
                                                                messageLikeList =
                                                                [];
                                                            for (int i = 0;
                                                                i <
                                                                    snapshot
                                                                        .data
                                                                        .docs
                                                                        .length;
                                                                i++) {
                                                              Map<String,
                                                                      String>
                                                                  messageLikeMap =
                                                                  {
                                                                'likedUserUid': snapshot
                                                                        .data
                                                                        .docs[i]
                                                                        .data()[
                                                                    'liked user uid']
                                                              };
                                                              messageLikeList.add(
                                                                  messageLikeMap);
                                                            }
                                                            return ListView
                                                                .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    scrollDirection:
                                                                        Axis
                                                                            .horizontal,
                                                                    itemCount:
                                                                        messageLikeList
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      print(
                                                                          'we have made it till listView ${messageLikeList.length}');
                                                                      print(
                                                                          'we have made it till listView $messageLikeList');
                                                                      return Container(
                                                                          height:
                                                                              20,
                                                                          //width: 20,
                                                                          child: StreamBuilder<DocumentSnapshot>(
                                                                              stream: DatabaseService(uid: messageLikeList[index]['likedUserUid']).getUserProfile(),
                                                                              builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                                                                                if (snap.hasData) {
                                                                                  Map<String, dynamic> documentFields = snap.data.data();
                                                                                  print('j profileImgs are ${documentFields['profileImg']}');
                                                                                  return Row(children: [
                                                                                    Container(child: CircleAvatar(radius: 10, backgroundImage: NetworkImage(documentFields['profileImg']), backgroundColor: Colors.grey))
                                                                                  ]);
                                                                                } else {
                                                                                  //print('returning')
                                                                                  return Container();
                                                                                }
                                                                              }));
                                                                    });
                                                          } else {
                                                            return Container();
                                                          }
                                                        }))
                                              ]))
                                    ]),
                              ]))),
          ]);
  }
}
