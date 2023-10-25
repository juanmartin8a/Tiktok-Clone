import 'package:flutter/material.dart';
import 'package:tiktokClone/screens/home/main/for_you_child.dart';
import 'package:tiktokClone/screens/home/notifications/notifications.dart';
import 'package:tiktokClone/screens/home/profile/profile.dart';
import 'package:tiktokClone/screens/home/search/search.dart';
import 'package:tiktokClone/screens/home/upload/uplaod_vid.dart';
import '../../../services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForYou extends StatefulWidget {
  @override
  _ForYouState createState() => _ForYouState();
}

class _ForYouState extends State<ForYou> {
  final PageController ctrl = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        //appBar: AppBar(),
        body: StreamBuilder<QuerySnapshot>(
            stream: DatabaseService().getForYouVideos(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              print('before hasData');
              if (snapshot.hasData) {
                print('after hasData');
                //print('working, the vid is ${snapshot.data.docs[0].data()['profileImg']}');
                List<Map<String, String>> postsList = [];
                for (int i = 0; i < snapshot.data.docs.length; i++) {
                  print(
                      'working, the vid is ${snapshot.data.docs[i].data()['profileImg']}');
                  Map<String, String> theList = {
                    'forYouPosts': snapshot.data.docs[i].data()['profileImg'],
                    'uid': snapshot.data.docs[i].data()['uid'],
                    'cap': snapshot.data.docs[i].data()['cap'],
                    'id': snapshot.data.docs[i].data()['id'],
                  };
                  postsList.add(theList);
                }
                if (0 < postsList.length) {
                  return PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: ctrl,
                      itemCount: postsList.length,
                      itemBuilder: (context, int index) {
                        print('index is ${postsList[index]['forYouPosts']}');
                        print(index);
                        if (0 < index) {
                          print(postsList[index]['forYouPosts']);
                        }
                        return ForYouChild(
                          index: index,
                          snapLength: snapshot.data.docs.length,
                          postsList: postsList[index]['forYouPosts'],
                          cap: postsList[index]['cap'],
                          uid: postsList[index]['uid'],
                          id: postsList[index]['id'],
                          isOnForYou: true,
                        );
                      });
                } else if (0 > postsList.length) {
                  return Container(
                    child: Stack(
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text('TikTok Clone')),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Colors.grey, width: 0.2))),
                              height: 45,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                              padding: EdgeInsets.zero,
                                              color: Colors.grey[50],
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
                                                      color: Colors.grey[50],
                                                      fontSize: 11)))
                                        ],
                                      )),
                                  Container(
                                      height: 35,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                              color: Colors.grey[700],
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
                                                    color: Colors.grey[700],
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
                return Container(color: Colors.red, child: Text('nothing'));
              }
            }));
  }
}
