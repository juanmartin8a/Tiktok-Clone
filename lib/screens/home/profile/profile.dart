import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/auth/signin.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/notifications/notifications.dart';
import 'package:tiktokClone/screens/home/profile/profile_posts.dart';
import 'package:tiktokClone/screens/home/search/search.dart';
import 'package:tiktokClone/screens/home/upload/uplaod_vid.dart';
import 'package:tiktokClone/screens/wrapper.dart';
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

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _auth = AuthService();
  int followerCount = 0;
  int followingCount = 0;
  int likeCount = 0;

  @override
  void initState() {
    getFollowingCount(context);
    getFollowerCount(context);
    super.initState();
  }

  getFollowerCount(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(uid: user.uid).countFollowerDocuments().then((value) {
      print(value);
      setState(() {
        followerCount = value;
      });
    });
  }

  getFollowingCount(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(uid: user.uid)
        .countFollowingDocuments()
        .then((value) {
      print(value);
      setState(() {
        followingCount = value;
      });
    });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService(uid: user.uid).getUserProfile(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> documentFields = snapshot.data.data();
            return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  actions: [
                    FlatButton.icon(
                        icon: Icon(Icons.person),
                        label: Text('logout'),
                        onPressed: () async {
                          await _auth.signOut();
                        }),
                  ],
                  bottom: PreferredSize(
                    child: Container(
                      color: Colors.grey[800],
                      height: 0.2,
                    ),
                    preferredSize: Size.fromHeight(0.2),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.grey[50],
                  title: Text(documentFields['name'],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          letterSpacing: 0.68)),
                  centerTitle: true,
                ),
                body: Container(
                    constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    ),
                    padding: EdgeInsets.only(top: 20),
                    color: Colors.transparent,
                    child: Stack(children: [
                      Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  child: CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    NetworkImage(documentFields['profileImg']),
                                backgroundColor: Colors.grey[300],
                              )),
                              Container(
                                margin: EdgeInsets.only(top: 12),
                                child: Text('@${documentFields['name']}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17, letterSpacing: .085)),
                              ),
                              Container(
                                  height: 40,
                                  margin: EdgeInsets.only(top: 18),
                                  child: FractionallySizedBox(
                                      widthFactor: 0.60,
                                      child: Container(
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyFollowings(
                                                                userUID:
                                                                    user.uid)));
                                              },
                                              child: Column(children: [
                                                Text(
                                                  '$followingCount',
                                                ),
                                                Text('Following',
                                                    style: TextStyle(
                                                        fontSize: 12.5))
                                              ]),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyFollowers(
                                                                userUID:
                                                                    user.uid)));
                                                //widget.followers;
                                              },
                                              child: Column(children: [
                                                Text(
                                                  '$followerCount',
                                                ),
                                                Text('Followers',
                                                    style: TextStyle(
                                                        fontSize: 12.5))
                                              ]),
                                            ),
                                            Column(children: [
                                              Text(
                                                '$likeCount',
                                              ),
                                              Text('Likes',
                                                  style:
                                                      TextStyle(fontSize: 12.5))
                                            ])
                                          ])))),
                              Container(
                                  height: 40,
                                  margin: EdgeInsets.only(top: 18),
                                  child: FractionallySizedBox(
                                      widthFactor: 0.50,
                                      child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey[300])),
                                          child: MaterialButton(
                                            //padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Text('Edit profile',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    letterSpacing: .085)),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfile(
                                                            name:
                                                                documentFields[
                                                                    'name'],
                                                            bio: documentFields[
                                                                'bio'],
                                                            profileImg:
                                                                documentFields[
                                                                    'profileImg'])),
                                              );
                                            },
                                          )))),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Text(documentFields['bio'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15.5)),
                              ),
                              Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                              color: Colors.grey[400],
                                              width: 0.3),
                                          bottom: BorderSide(
                                              color: Colors.grey[400],
                                              width: 0.3))),
                                  child:
                                      Icon(Icons.reorder, color: Colors.black)),
                              Container(
                                  child: FutureBuilder(
                                      future: DatabaseService().getProfilePosts(
                                          documentFields['uid']),
                                      builder: (context, postSnap) {
                                        if (postSnap.hasData) {
                                          List<Map<String, String>> postList =
                                              [];
                                          for (int i = 0;
                                              i < postSnap.data.docs.length;
                                              i++) {
                                            Map<String, String> iList = {
                                              'profilePosts': postSnap
                                                  .data.docs[i]
                                                  .data()['profileImg'],
                                              'id': postSnap.data.docs[i]
                                                  .data()['id'],
                                              'uid': postSnap.data.docs[i]
                                                  .data()['uid'],
                                            };
                                            postList.add(iList);
                                          }
                                          print(
                                              'of course it has data ${postList.length}');
                                          return Expanded(
                                              child: GridView.count(
                                                  primary: false,
                                                  crossAxisCount: 3,
                                                  childAspectRatio: (9 / 12),
                                                  children: List.generate(
                                                      postList.length,
                                                      (int index) {
                                                    return Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: ProfilePosts(
                                                          index: index,
                                                          videoUrl: postList[
                                                                  index]
                                                              ['profilePosts'],
                                                          videoId:
                                                              postList[index]
                                                                  ['id'],
                                                          myUid: postList[index]
                                                              ['uid'],
                                                        ));
                                                  })));
                                        } else {
                                          return Container();
                                        }
                                      }))
                            ],
                          )),
                    ])),
                //Text(documentFields['name']);
                bottomNavigationBar: BottomAppBar(
                    color: Colors.grey[50],
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey[800], width: 0.2))),
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
                                                builder: (context) =>
                                                    ForYou())),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Text('Home',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 11)))
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
                                                  builder: (context) =>
                                                      SearchScreen())),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Text('Discover',
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 11)))
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
                                                builder: (context) =>
                                                    Notifications())),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Text('Inbox',
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 11))),
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
                                                builder: (context) =>
                                                    Profile())),
                                      )),
                                  Expanded(
                                      flex: 2,
                                      child: Text('Me',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11)))
                                ]))
                          ],
                        ))));
          } else {
            return Container();
          }
        });
  }
}
