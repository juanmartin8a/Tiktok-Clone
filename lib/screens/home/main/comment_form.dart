import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/comments.dart';
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

class Comments extends StatefulWidget {
  final String id;
  final String uid;
  Comments({this.id, this.uid});
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  TextEditingController _commentController = TextEditingController();
  final String commentId = DatabaseService().commentId;

  addComment(String name) {
    if (_commentController.text.isNotEmpty) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.id)
          .collection('comments')
          .doc();
      final user = Provider.of<CustomUser>(context, listen: false);
      Map<String, dynamic> commentMap = {
        'comment': _commentController.text,
        'userUid': user.uid,
        'id': docRef.id,
        'userName': name,
        'videoUserUid': widget.uid,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService(uid: widget.id, docId: commentId)
          .commentVideo(commentMap, docRef);
      setState(() {
        _commentController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context, listen: false);
    return Container(
        height: MediaQuery.of(context).size.height * 0.60,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: new BoxDecoration(
            color: Colors.grey[50],
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(7.0),
                topRight: const Radius.circular(7.0))),
        child: Container(
            child: Stack(children: [
          Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService(uid: widget.id).getComments(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      List<Map<String, String>> theList = [];
                      for (int i = 0; i < snapshot.data.docs.length; i++) {
                        Map<String, String> theMap = {
                          'comment': snapshot.data.docs[i].data()['comment'],
                          'userUid': snapshot.data.docs[i].data()['userUid']
                        };
                        theList.add(theMap);
                      }
                      print(theList);
                      return ListView.builder(
                          itemCount: theList.length,
                          itemBuilder: (context, int index) {
                            print('the list length id ${theList.length}');
                            print('the current index is $index');
                            return FutureBuilder(
                                future: DatabaseService(uid: widget.id)
                                    .queryComments(theList[index]['userUid']),
                                builder: (context, snap) {
                                  if (snap.connectionState ==
                                      ConnectionState.done) {
                                    List<Map<String, String>> theQueriedList =
                                        [];
                                    for (int i = 0; i < theList.length; i++) {
                                      for (int j = 0;
                                          j < snap.data.docs.length;
                                          j++) {
                                        Map<String, String> theQueriedMap = {
                                          'comment': snapshot.data.docs[i]
                                              .data()['comment'],
                                          'id': snapshot.data.docs[i]
                                              .data()['id'],
                                          'userUid': snapshot.data.docs[i]
                                              .data()['userUid'],
                                          'profileImg': snap.data.docs[j]
                                              .data()['profileImg'],
                                          'name':
                                              snap.data.docs[j].data()['name']
                                        };
                                        theQueriedList.add(theQueriedMap);
                                      }
                                    }
                                    print(
                                        'the queried list is $theQueriedList');
                                    return CommentsChild(
                                      comment: theQueriedList[index]['comment'],
                                      commentId: theQueriedList[index]['id'],
                                      userUid: theQueriedList[index]['userUid'],
                                      profileImg: theQueriedList[index]
                                          ['profileImg'],
                                      name: theQueriedList[index]['name'],
                                      videoId: widget.id,
                                      length: theList.length,
                                    );
                                  } else {
                                    return Container();
                                  }
                                });
                          });
                    } else {
                      return Container();
                    }
                  })),
          Container(
              alignment: Alignment.bottomCenter,
              constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              child: Container(
                  height: 50,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: TextField(
                                      controller: _commentController,
                                      decoration: InputDecoration(
                                        hintText: 'Add comment...',
                                      ))),
                              Expanded(
                                  flex: 1,
                                  child: StreamBuilder<DocumentSnapshot>(
                                      stream: DatabaseService(uid: user.uid)
                                          .getUserProfile(),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          print('yes, it has data!');
                                          Map<String, dynamic> currentUserDocs =
                                              snapshot.data.data();
                                          return IconButton(
                                              icon: Icon(Icons.send),
                                              onPressed: () {
                                                addComment(
                                                    currentUserDocs['name']);
                                              });
                                        } else {
                                          return IconButton(
                                              icon: Icon(Icons.send),
                                              onPressed: () {
                                                //addComment();
                                              });
                                        }
                                      })),
                            ])
                      ])))
        ])));
  }
}
