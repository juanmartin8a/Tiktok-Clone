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

class FollowersChild extends StatefulWidget {
  final String indexUid;
  final String dataName;
  final String followerName;
  FollowersChild({this.indexUid, this.dataName, this.followerName});

  @override
  _FollowersChildState createState() => _FollowersChildState();
}

class _FollowersChildState extends State<FollowersChild> {
  bool userIsFollowing = false;
  int followerCount = 0;
  int followingCount = 0;
  QuerySnapshot followerSnapshot;
  DatabaseService databaseService = DatabaseService();
  @override
  @override
  void initState() {
    getFollowerState(context, widget.indexUid);
    super.initState();
  }

  getFollowerState(BuildContext context, String followerUid) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(uid: user.uid)
        .getUserFollowing(followerUid)
        .then((value) {
      print('value is $value');
      setState(() {
        userIsFollowing = value;
      });
    });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return Container(
        width: 94,
        height: 26,
        child: userIsFollowing
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.6,
                    color: Colors.grey[400],
                  ),
                ),
                child: MaterialButton(
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                  color: Colors.grey[50],
                  child: Text('Following',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: .5,
                          color: Colors.grey[900])),
                  onPressed: () {
                    DatabaseService(uid: widget.indexUid)
                        .deleteFollower(user.uid);
                    DatabaseService(uid: user.uid)
                        .deleteFollowing(widget.indexUid);
                    //getFollowingState(context, widget.indexUid);
                  },
                ))
            : MaterialButton(
                color: Colors.pink,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                child: Text('Follow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, letterSpacing: .5, color: Colors.white)),
                onPressed: () {
                  Map<String, String> follower = {
                    'follower': widget.dataName,
                    'following': widget.indexUid,
                    'followerUid': user.uid,
                  };
                  Map<String, String> following = {
                    'follower': widget.followerName,
                    'beingFollower': user.uid,
                    'followerUid': widget.indexUid,
                  };
                  DatabaseService(uid: widget.indexUid)
                      .addFollowerList(user.uid, follower);
                  DatabaseService(uid: user.uid)
                      .addFollowingList(widget.indexUid, following);
                  //getFollowerState(context, widget.indexUid);
                },
              ));
  }
}
