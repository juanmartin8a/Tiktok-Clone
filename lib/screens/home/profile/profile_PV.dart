import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/main/for_you_child.dart';
import 'package:tiktokClone/screens/home/notifications/notifications.dart';
import 'package:tiktokClone/screens/home/profile/PageView_child.dart';
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

class ProfilePageView extends StatefulWidget {
  final String myUid;
  final String videoUrl;
  final int currentIndex;
  ProfilePageView({this.currentIndex, this.myUid, this.videoUrl});
  @override
  _ProfilePageViewState createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends State<ProfilePageView> {
  PageController ctrl;

  @override
  void initState() {
    ctrl = PageController(initialPage: widget.currentIndex);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        //appBar: AppBar(),
        body: Stack(children: [
          FutureBuilder(
              future: DatabaseService().getProfilePosts(widget.myUid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, String>> postList = [];
                  for (int i = 0; i < snapshot.data.docs.length; i++) {
                    Map<String, String> iList = {
                      'profilePosts':
                          snapshot.data.docs[i].data()['profileImg'],
                      'id': snapshot.data.docs[i].data()['id'],
                      'cap': snapshot.data.docs[i].data()['cap'],
                      'uid': snapshot.data.docs[i].data()['uid'],
                    };
                    postList.add(iList);
                  }
                  return PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: ctrl,
                      itemCount: postList.length,
                      itemBuilder: (context, index) {
                        return ProfilePVChild(
                          index: widget.currentIndex,
                          snapLength: snapshot.data.docs.length,
                          postsList: postList[index]['profilePosts'],
                          cap: postList[index]['cap'],
                          uid: postList[index]['uid'],
                          id: postList[index]['id'],
                        );
                      });
                } else {
                  return Container();
                }
              }),
          Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: AppBar(
                title: Text(''), // You can add title here
                leading: new IconButton(
                  icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                backgroundColor: Colors.black
                    .withOpacity(0.01), //You can make this transparent
                elevation: 0.0, //No shadow
              )),
        ]));
  }
}
