import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/notifications/conversation_screen.dart';
import 'package:tiktokClone/screens/home/profile/profile.dart';
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
//import 'edit_profile.dart';
import '../../../models/username.dart';

class ChatRoomTile extends StatefulWidget {
  final String myName;
  final String myUid;
  final String userName;
  final String myProPic;
  final String proPic;
  ChatRoomTile(
      {this.myName, this.myProPic, this.proPic, this.userName, this.myUid});
  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  final DatabaseService databaseService = DatabaseService();
  Stream chatRoomStream;

  @override
  void initState() {
    getChatRooms();
    super.initState();
  }

  getChatRooms() async {
    databaseService.getChatRooms(widget.myUid).then((snapshots) {
      setState(() {
        chatRoomStream = snapshots;
      });
    });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    print('made it to chat rooms');
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
          backgroundColor: Colors.grey[50],
          title: Text('Direct messages',
              style: TextStyle(
                  color: Colors.black, fontSize: 18, letterSpacing: 0.68)),
          centerTitle: true,
        ),
        body: Container(
          child: StreamBuilder(
              stream: chatRoomStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print('made it to stream builder');
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        print('made it to chatroom listview');

                        return StreamBuilder<DocumentSnapshot>(
                            stream: snapshot.data.docs[index].data()['user1'] !=
                                    widget.myUid
                                ? DatabaseService(
                                        uid: snapshot.data.docs[index]
                                            .data()['user1'])
                                    .getUserProfile()
                                : DatabaseService(
                                        uid: snapshot.data.docs[index]
                                            .data()['user2'])
                                    .getUserProfile(),
                            builder: (context, snap) {
                              if (snap.hasData) {
                                Map<String, dynamic> currentUserdocs =
                                    snap.data.data();
                                print(
                                    'USER1 FIELD IS ${currentUserdocs['name']}');
                                return
                                    //});
                                    GestureDetector(
                                        onTap: () {
                                          //print(chatRoom);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ConversationScreen(
                                                        chatRoomId: snapshot
                                                                .data
                                                                .docs[index]
                                                                .data()[
                                                            'chatroomId'],
                                                        myName: widget.myName,
                                                        myProPic:
                                                            widget.myProPic,
                                                        myUid: widget.myUid,
                                                        userName:
                                                            currentUserdocs[
                                                                'name'],
                                                        proPic: currentUserdocs[
                                                            'profileImg'],
                                                      )));
                                        },
                                        child: Container(
                                            padding: EdgeInsets.only(
                                                top: 17, left: 20),
                                            child: Row(children: [
                                              Container(
                                                  child: CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              currentUserdocs[
                                                                  'profileImg']))),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(left: 8),
                                                  child: Text(
                                                      currentUserdocs['name'],
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          letterSpacing: 0.65)))
                                            ])));
                              } else {
                                return Container();
                              }
                            });
                      });
                  //});
                } else {
                  return Container();
                }
              }),
        ));
  }
}
