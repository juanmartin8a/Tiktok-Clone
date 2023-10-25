import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/profile/profiles.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../models/username.dart';
import 'package:tiktokClone/screens/home/profile/followers_child.dart';
//import 'search_tile.dart';

class Followers extends StatefulWidget {
  final String userUID;
  Followers({this.userUID});
  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  bool userIsFollowing = false;
  int followerCount = 0;
  int followingCount = 0;
  QuerySnapshot followerSnapshot;
  DatabaseService databaseService = DatabaseService();

  @override
  void initState() {
    getFollowerState(context);
    getFollowingCount(context);
    getFollowerCount(context);
    super.initState();
  }

  getFollowerState(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(uid: widget.userUID)
        .getUserFollowing(user.uid)
        .then((value) {
      print('value is $value');
      setState(() {
        userIsFollowing = value;
      });
    });
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
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          bottom: PreferredSize(
            child: Container(
              color: Colors.grey[800],
              height: 0.2,
            ),
            preferredSize: Size.fromHeight(0.2),
          ),
          elevation: 0,
          title: Text('Followers',
              style: TextStyle(
                  color: Colors.black, fontSize: 18, letterSpacing: 0.68)),
          centerTitle: true,
          backgroundColor: Colors.grey[50],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: DatabaseService(uid: widget.userUID).getUserFollowers(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                List<Map<String, String>> list = [];

                for (int i = 0; i < snapshot.data.docs.length; i++) {
                  print(snapshot.data.docs[i].data()['followerUid']);
                  print(snapshot.data.docs[i].data()['follower']);
                  Map<String, String> listMap = {
                    'follower': snapshot.data.docs[i].data()['follower'],
                    'followerUid': snapshot.data.docs[i].data()['followerUid']
                  };
                  list.add(listMap);
                  //list(follower: snapshot.data.docs[i].data()['follower']);
                }
                print(snapshot.data.docs.length);
                print(list);

                return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                          future: databaseService
                              .queryUserFollowers(list[index]['followerUid']),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  itemCount: snapshot.data.docs.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                  child: CircleAvatar(
                                                radius: 25,
                                                backgroundImage: NetworkImage(
                                                    snapshot.data.docs[index]
                                                        .data()['profileImg']),
                                                backgroundColor:
                                                    Colors.grey[300],
                                              )),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(left: 8),
                                                  child: Text(
                                                    snapshot.data.docs[index]
                                                        .data()['name'],
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        letterSpacing: 0.5),
                                                  )),
                                            ],
                                          ),
                                          Container(
                                              child: StreamBuilder<UserData>(
                                                  stream: DatabaseService(
                                                          uid: user.uid)
                                                      .userData,
                                                  builder: (context, snap) {
                                                    UserData userData =
                                                        snap.data;
                                                    if (snap.hasData) {
                                                      return FollowersChild(
                                                        indexUid: snapshot
                                                            .data.docs[index]
                                                            .data()['uid'],
                                                        dataName: userData.name,
                                                        followerName: snapshot
                                                            .data.docs[index]
                                                            .data()['name'],
                                                      );
                                                    } else {
                                                      return Container();
                                                    }
                                                  })),
                                        ],
                                      ),
                                    );
                                  });
                            } else {
                              return Container();
                            }
                          });
                    });
                //]));
              } else {
                return Container();
              }
            }));
  }
}
