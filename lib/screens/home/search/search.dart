import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/notifications/notifications.dart';
import 'package:tiktokClone/screens/home/profile/profile.dart';
import 'package:tiktokClone/screens/home/profile/profiles.dart';
import 'package:tiktokClone/screens/home/upload/uplaod_vid.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../models/username.dart';
import 'search_tile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  DatabaseService databaseService = DatabaseService();
  QuerySnapshot searchSnapshot;

  searchList(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    print(searchSnapshot);
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTile(
                userName: searchSnapshot.docs[index].data()['name'],
                userEmail: searchSnapshot.docs[index].data()['email'],
                userUID: searchSnapshot.docs[index].data()['uid'],
                currentUserUID: user.uid,
              );
            },
          )
        : Container();
  }

  initializeSearch() async {
    if (searchController.text.isNotEmpty) {
      await databaseService
          .getUserByUsername(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
            width: MediaQuery.of(context).size.width * 0.90,
            child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                            height: 35,
                            child: Theme(
                                data: Theme.of(context).copyWith(
                                  primaryColor: Colors.black,
                                ),
                                child: TextField(
                                    onChanged: (val) {
                                      setState(() {
                                        initializeSearch();
                                      });
                                    },
                                    minLines: 1,
                                    maxLines: 1,
                                    controller: searchController,
                                    autofocus: false,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[350],
                                        hintText: 'Search',
                                        border: InputBorder.none,
                                        prefixIcon: Icon(Icons.search,
                                            color: Colors.black),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(0.0))))),
                      ),
                    ],
                  )
                ]))),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[50],
      ),
      body: Stack(children: [
        Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height,
              ),
              child: Column(children: [
                /*,*/
                Container(
                  child: searchList(context),
                )
              ]),
            )),
      ]),
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
                                color: Colors.black,
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchScreen())),
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Text('Discover',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 11)))
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
                                      color: Colors.grey[700], fontSize: 11))),
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
                                      builder: (context) => Profile())),
                            )),
                        Expanded(
                            flex: 2,
                            child: Text('Me',
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 11)))
                      ]))
                ],
              ))),
    );
  }
}
