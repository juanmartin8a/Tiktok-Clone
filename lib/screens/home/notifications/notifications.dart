import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/notifications/chat_rooms.dart';
import 'package:tiktokClone/screens/home/profile/profile.dart';
import 'package:tiktokClone/screens/home/search/search.dart';
import 'package:tiktokClone/screens/home/upload/uplaod_vid.dart';
import '../../../services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  _saveDeviceToken(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    String fcmToken = await _fcm.getToken();
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('usernames')
        .doc(user.uid)
        .collection('tokens')
        .doc();
    if (fcmToken != null) {
      Map<String, dynamic> tokenMap = {
        'token': fcmToken,
        'createdAt': '${FieldValue.serverTimestamp()}',
        'platform': Platform.operatingSystem,
        'id': docRef.id
      };
      DatabaseService(uid: user.uid).saveUserTokens(tokenMap, fcmToken);
    }
  }

  @override
  void initState() {
    super.initState();
    _fcm.configure(onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: ListTile(
            title: Text(message['notification']['title']),
            subtitle: Text(message['notification']['body']),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }, onLaunch: (Map<String, dynamic> message) async {
      print('onLaunch: $message');
    }, onResume: (Map<String, dynamic> message) async {
      print('onResume: $message');
    });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text('Inbox',
              style: TextStyle(
                  color: Colors.black, fontSize: 18, letterSpacing: 0.68)),
          centerTitle: true,
          backgroundColor: Colors.grey[50],
          actions: [
            StreamBuilder<DocumentSnapshot>(
                stream: DatabaseService(uid: user.uid).getUserProfile(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                  if (snap.hasData) {
                    Map<String, dynamic> currentUserdocs = snap.data.data();
                    return IconButton(
                      icon: Icon(Icons.send, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatRoomTile(
                                      myName: currentUserdocs['name'],
                                      myUid: currentUserdocs['uid'],
                                      myProPic: currentUserdocs['profileImg'],
                                    )));
                      },
                    );
                  } else {
                    return Container();
                  }
                })
          ],
        ),
        body: Container(
          child: Stack(children: [
            Container(
                child: StreamBuilder<QuerySnapshot>(
                    stream: DatabaseService(uid: user.uid).getNotifications(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        print('there are notifications');
                        List<Map<String, String>> notificationArray = [];
                        for (int i = 0; i < snapshot.data.docs.length; i++) {
                          Map<String, String> notificationMap = {
                            'title': snapshot.data.docs[i].data()['title'],
                            'body': snapshot.data.docs[i].data()['body'],
                            'notificationFor':
                                snapshot.data.docs[i].data()['notificationFor'],
                            'sendBy': snapshot.data.docs[i].data()['sendBy']
                          };
                          notificationArray.add(notificationMap);
                        }
                        return ListView.builder(
                            itemCount: notificationArray.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return StreamBuilder<DocumentSnapshot>(
                                stream: DatabaseService(
                                        uid: notificationArray[index]['sendBy'])
                                    .getUserProfile(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snap) {
                                  if (snap.hasData) {
                                    Map<String, dynamic> currentUserDocs =
                                        snap.data.data();
                                    return /*ListView.builder(
                                        itemCount: notificationArray.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return*/
                                        Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 10),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                      child: CircleAvatar(
                                                    radius: 24,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            currentUserDocs[
                                                                'profileImg']),
                                                    backgroundColor:
                                                        Colors.grey,
                                                  )),
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          left: 6),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              child: Text(
                                                                  currentUserDocs[
                                                                      'name'],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          800],
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          Container(
                                                              child: Text(
                                                                  notificationArray[
                                                                          index]
                                                                      ['body'],
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                            .grey[
                                                                        500],
                                                                  )))
                                                        ],
                                                      ))
                                                ]));
                                    //});
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            });
                      } else {
                        return Container();
                      }
                    })
                /*RaisedButton(
                    child: Text('hey!'),
                    onPressed: () {
                      _saveDeviceToken(context);
                    })*/
                ),
          ]),
        ),
        bottomNavigationBar: BottomAppBar(
            color: Colors.grey[50],
            child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.grey[800], width: 0.2))),
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
                                        builder: (context) => ForYou())),
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Text('Home',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 11)))
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
                                        builder: (context) => Notifications())),
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
                                        builder: (context) => Profile())),
                              )),
                          Expanded(
                              flex: 2,
                              child: Text('Me',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 11)))
                        ]))
                  ],
                ))));
  }
}
