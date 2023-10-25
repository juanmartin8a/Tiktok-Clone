import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/notifications/conversation_screen.dart';
import 'package:tiktokClone/screens/home/profile/followers.dart';
import 'package:tiktokClone/screens/home/profile/followings.dart';
import 'package:tiktokClone/screens/home/profile/profile_posts.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'edit_profile.dart';
import '../../../models/username.dart';

class Profiles extends StatefulWidget {
  final String userUID;
  final String currentUserUID;
  //final Function followers;
  Profiles({
    this.userUID,
    this.currentUserUID,
    /*this.followers*/
  });
  @override
  _ProfilesState createState() => _ProfilesState();
}

//bool userIsFollowing = false;

class _ProfilesState extends State<Profiles> {
  //QuerySnapshot profileSnapshot;
  bool userIsFollowing = false;
  int followerCount = 0;
  int followingCount = 0;
  int likeCount = 0;
  QuerySnapshot followerSnapshot;
  DatabaseService databaseService = DatabaseService();

  getFollowers() async {
    await databaseService.getUserFollowers().then((snapshot) {
      print(snapshot.docs.data());
    });
  }

  createChatroomAndStartConversation(String userName, String myName,
      String myProPic, String propic, String myUid, String userUid) {
    if (userUid != myUid) {
      List<String> users = [userUid, myUid];
      print(users);
      String chatRoomId = getChatRoomId(userName, myName);
      print('constant name below');
      print(myName);
      Map<String, dynamic> chatRoomMap = {
        'users': users,
        'user1': userUid,
        'user2': myUid,
        'chatroomId': chatRoomId,
      };
      DatabaseService().createChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(
                    chatRoomId: chatRoomId,
                    myName: myName,
                    userName: userName,
                    myProPic: myProPic,
                    proPic: propic,
                  )));
    } else {
      print('cannot text yourself');
    }
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    getFollowingState(context);
    getFollowingCount();
    getFollowerCount();
    super.initState();
  }

  getFollowingState(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(uid: widget.userUID)
        .getUserFollower(user.uid)
        .then((value) {
      print(value);
      setState(() {
        userIsFollowing = value;
      });
    });
  }

  getFollowerCount() async {
    await DatabaseService(uid: widget.userUID)
        .countFollowerDocuments()
        .then((value) {
      print(value);
      setState(() {
        followerCount = value;
      });
    });
  }

  getFollowingCount() async {
    await DatabaseService(uid: widget.userUID)
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
        stream: DatabaseService(uid: widget.userUID).getUserProfile(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> documentFields = snapshot.data.data();
            return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  title: Text(documentFields['name'],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          letterSpacing: 0.68)),
                  centerTitle: true,
                  bottom: PreferredSize(
                    child: Container(
                      color: Colors.grey[800],
                      height: 0.2,
                    ),
                    preferredSize: Size.fromHeight(0.2),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.grey[50],
                ),
                body: Container(
                    constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    ),
                    padding: EdgeInsets.only(top: 20),
                    color: Colors.transparent,
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
                              style:
                                  TextStyle(fontSize: 17, letterSpacing: .085)),
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
                                                      Followings(
                                                          userUID:
                                                              widget.userUID)));
                                        },
                                        child: Column(children: [
                                          Text(
                                            '$followingCount',
                                          ),
                                          Text('Following',
                                              style: TextStyle(fontSize: 12.5))
                                        ]),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Followers(
                                                          userUID:
                                                              widget.userUID)));
                                          //widget.followers;
                                        },
                                        child: Column(children: [
                                          Text(
                                            '$followerCount',
                                          ),
                                          Text('Followers',
                                              style: TextStyle(fontSize: 12.5))
                                        ]),
                                      ),
                                      Column(children: [
                                        Text(
                                          '$likeCount',
                                        ),
                                        Text('Likes',
                                            style: TextStyle(fontSize: 12.5))
                                      ])
                                    ])))),
                        Container(
                            height: 40,
                            margin: EdgeInsets.only(top: 18),
                            child: FractionallySizedBox(
                                widthFactor: 0.50,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[300])),
                                  child: StreamBuilder<UserData>(
                                      stream: DatabaseService(uid: user.uid)
                                          .userData,
                                      builder: (context, snapshot) {
                                        UserData userData = snapshot.data;
                                        return userIsFollowing
                                            ? Row(children: [
                                                Expanded(
                                                    flex: 4,
                                                    child: MaterialButton(
                                                      //padding: EdgeInsets.symmetric(vertical: 8),
                                                      child: Text('Message',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              letterSpacing:
                                                                  .085)),
                                                      onPressed: () {
                                                        DatabaseService(
                                                                uid: widget
                                                                    .userUID)
                                                            .deleteFollower(
                                                                user.uid);
                                                        DatabaseService(
                                                                uid: user.uid)
                                                            .deleteFollowing(
                                                                documentFields[
                                                                    'uid']);
                                                        getFollowingState(
                                                            context);
                                                        getFollowerCount();
                                                        getFollowingCount();
                                                      },
                                                    )),
                                                StreamBuilder<DocumentSnapshot>(
                                                    stream: DatabaseService(
                                                            uid: user.uid)
                                                        .getUserProfile(),
                                                    builder: (context,
                                                        AsyncSnapshot<
                                                                DocumentSnapshot>
                                                            snap) {
                                                      if (snap.hasData) {
                                                        Map<String, dynamic>
                                                            currentUserdocs =
                                                            snap.data.data();
                                                        return Expanded(
                                                            child: IconButton(
                                                                icon: Icon(Icons
                                                                    .message),
                                                                onPressed: () {
                                                                  createChatroomAndStartConversation(
                                                                      documentFields[
                                                                          'name'],
                                                                      currentUserdocs[
                                                                          'name'],
                                                                      currentUserdocs[
                                                                          'profileImg'],
                                                                      documentFields[
                                                                          'profileImg'],
                                                                      currentUserdocs[
                                                                          'uid'],
                                                                      documentFields[
                                                                          'uid']);
                                                                }));
                                                      } else {
                                                        return Container();
                                                      }
                                                    })
                                              ])
                                            : MaterialButton(
                                                color: Colors.redAccent[400],
                                                //padding: EdgeInsets.symmetric(vertical: 8),
                                                child: Text('Follow',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        letterSpacing: .085)),
                                                onPressed: () {
                                                  Map<String, dynamic>
                                                      follower = {
                                                    'follower': userData.name,
                                                    'following':
                                                        documentFields['uid'],
                                                    'followerUid': user.uid,
                                                    'time': DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                  };
                                                  Map<String, String>
                                                      following = {
                                                    'follower':
                                                        documentFields['name'],
                                                    'beingFollower': user.uid,
                                                    'followerUid':
                                                        documentFields['uid'],
                                                  };
                                                  DatabaseService(
                                                          uid: widget.userUID)
                                                      .addFollowerList(
                                                          user.uid, follower);
                                                  DatabaseService(uid: user.uid)
                                                      .addFollowingList(
                                                          documentFields['uid'],
                                                          following);
                                                  getFollowingState(context);
                                                  getFollowerCount();
                                                  getFollowingCount();
                                                },
                                              );
                                      }),
                                ))),
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
                                        color: Colors.grey[400], width: 0.3),
                                    bottom: BorderSide(
                                        color: Colors.grey[400], width: 0.3))),
                            child: Icon(Icons.reorder, color: Colors.black)),
                        Container(
                            child: FutureBuilder(
                                future: DatabaseService()
                                    .getProfilePosts(documentFields['uid']),
                                builder: (context, postSnap) {
                                  if (postSnap.hasData) {
                                    List<Map<String, String>> postList = [];
                                    for (int i = 0;
                                        i < postSnap.data.docs.length;
                                        i++) {
                                      Map<String, String> iList = {
                                        'profilePosts': postSnap.data.docs[i]
                                            .data()['profileImg'],
                                        'id':
                                            postSnap.data.docs[i].data()['id'],
                                        'uid':
                                            postSnap.data.docs[i].data()['uid'],
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
                                                postList.length, (int index) {
                                              return Align(
                                                  alignment: Alignment.center,
                                                  child: ProfilePosts(
                                                    index: index,
                                                    videoUrl: postList[index]
                                                        ['profilePosts'],
                                                    videoId: postList[index]
                                                        ['id'],
                                                    myUid: postList[index]
                                                        ['uid'],
                                                  ));
                                            })));
                                  } else {
                                    return Container();
                                  }
                                })),
                      ],
                    )));
            //Text(documentFields['name']);
          } else {
            return Container();
          }
        });
  }
}
