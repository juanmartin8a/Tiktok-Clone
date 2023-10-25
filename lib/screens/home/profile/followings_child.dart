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

class FollowingsChild extends StatefulWidget {
  final String indexUid;
  final String dataName;
  final String followerName;
  FollowingsChild({this.indexUid, this.dataName, this.followerName});

  @override
  _FollowingsChildState createState() => _FollowingsChildState();
}

class _FollowingsChildState extends State<FollowingsChild> {
  bool userIsFollowing = false;
  int followerCount = 0;
  int followingCount = 0;
  QuerySnapshot followerSnapshot;
  DatabaseService databaseService = DatabaseService();
  @override
  @override
  void initState() {
    getFollowingState(context, widget.indexUid);
    super.initState();
  }

  getFollowingState(BuildContext context, String followerUid) async {
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
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                color: Colors.pink,
                //padding: EdgeInsets.symmetric(vertical: 8),
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
                  //getFollowingState(context, widget.indexUid);
                },
              ));
  }
}
