import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/main/for_you_child.dart';
import 'package:tiktokClone/screens/home/notifications/notifications.dart';
import 'package:tiktokClone/screens/home/profile/profile.dart';
import 'package:tiktokClone/screens/home/profile/profiles.dart';
import 'package:tiktokClone/screens/home/search/search.dart';
import 'package:tiktokClone/screens/home/upload/uplaod_vid.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/username.dart';
import 'package:video_player/video_player.dart';

class FollowingVideos extends StatefulWidget {
  @override
  _FollowingVideosState createState() => _FollowingVideosState();
}

class _FollowingVideosState extends State<FollowingVideos> {
  final PageController ctrl = PageController();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: StreamBuilder<QuerySnapshot>(
            stream: DatabaseService(uid: user.uid).getUserFollowings(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                //List<Map<String, String>> list = [];
                return PageView(
                    children:
                        snapshot.data.docs.map<Widget>((DocumentSnapshot doc) {
                  print('the doc 1 is ${doc.data()['followerUid']}');
                  //}).toList();
                  /*for (int i = 0; i < snapshot.data.docs.length; i++) {
                    Map<String, String> listMap = {
                      'followerUid': snapshot.data.docs[i].data()['followerUid']
                    };
                    list.add(listMap);
                  }*/
                  /*PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: ctrl,
                    //primary: false,
                    //shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      /*print(
                          'list followerUid is ${list[index]['followerUid']}');*/
                      return*/
                  return FutureBuilder(
                      future: DatabaseService()
                          .getFollowingVideos(doc.data()['followerUid']),
                      builder: (context, snap) {
                        if (snap.hasData) {
                          List<Map<String, String>> fVList = [];
                          for (int i = 0; i < snap.data.docs.length; i++) {
                            Map<String, String> listMap = {
                              'forYouPosts':
                                  snap.data.docs[i].data()['profileImg'],
                              'uid': snap.data.docs[i].data()['uid'],
                              'cap': snap.data.docs[i].data()['cap'],
                              'id': snap.data.docs[i].data()['id'],
                            };
                            fVList.add(listMap);
                          }
                          print('following video $fVList');
                          if (0 <= fVList.length) {
                            return PageView.builder(
                                scrollDirection: Axis.vertical,
                                controller: ctrl,
                                // shrinkWrap: true,
                                itemCount: fVList.length,
                                itemBuilder: (context, int index) {
                                  print(
                                      'index is ${fVList[index]['forYouPosts']}');
                                  print(index);
                                  /*if (0 < index) {
                                          print(fVList[index]['forYouPosts']);
                                        }*/
                                  return ForYouChild(
                                    index: index,
                                    snapLength: snap.data.docs.length,
                                    postsList: fVList[index]['forYouPosts'],
                                    cap: fVList[index]['cap'],
                                    uid: fVList[index]['uid'],
                                    id: fVList[index]['id'],
                                    isOnForYou: false,
                                  );
                                });
                          } else if (0 > fVList.length) {
                            return Container(
                              child: Stack(
                                children: [
                                  Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          'Follow people to see thir content',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                top: BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.2))),
                                        height: 45,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                                height: 35,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      flex: 5,
                                                      child: IconButton(
                                                        icon: Icon(Icons.home),
                                                        iconSize: 30,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        color: Colors.grey[50],
                                                        onPressed: () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ForYou())),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text('Home',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[50],
                                                                fontSize: 11)))
                                                  ],
                                                )),
                                            Container(
                                                height: 35,
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: IconButton(
                                                          icon: Icon(
                                                              Icons.search),
                                                          iconSize: 30,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          color:
                                                              Colors.grey[600],
                                                          onPressed: () => Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SearchScreen())),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                              'Discover',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize:
                                                                      11)))
                                                    ])),
                                            IconButton(
                                                icon: Icon(Icons.add_box),
                                                iconSize: 30,
                                                color: Colors.white,
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            VideoUpload()))),
                                            Container(
                                                height: 35,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      flex: 5,
                                                      child: IconButton(
                                                        icon: Icon(Icons.inbox),
                                                        iconSize: 27,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        color: Colors.grey[700],
                                                        onPressed: () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Notifications())),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text('Inbox',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                                fontSize: 11))),
                                                  ],
                                                )),
                                            Container(
                                                height: 35,
                                                child: Column(children: [
                                                  Expanded(
                                                      flex: 5,
                                                      child: IconButton(
                                                        icon:
                                                            Icon(Icons.person),
                                                        iconSize: 30,
                                                        color: Colors.grey[700],
                                                        padding:
                                                            EdgeInsets.zero,
                                                        onPressed: () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Profile())),
                                                      )),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text('Me',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                              fontSize: 11)))
                                                ]))
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          print('has no data 2');
                          return Container();
                        }
                      });
                  //});
                }).toList());
              } else {
                print('has no data 1');
                return Container();
              }
            }));
  }
}
