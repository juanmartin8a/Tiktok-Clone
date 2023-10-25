import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../models/username.dart';
import '../profile/profiles.dart';

class SearchTile extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userUID;
  final String currentUserUID;
  SearchTile({
    this.userName,
    this.userEmail,
    this.userUID,
    this.currentUserUID,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService(uid: userUID).getUserProfile(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> userDocs = snapshot.data.data();
            return Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profiles(
                                  userUID: userUID,
                                  currentUserUID: currentUserUID)));
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(children: [
                          Container(
                              child: CircleAvatar(
                            radius: 23,
                            backgroundImage:
                                NetworkImage(userDocs['profileImg']),
                            backgroundColor: Colors.grey,
                          )),
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            //flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      letterSpacing: 0.38),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 3),
                                  child: Text(
                                    userEmail,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ]))));
          } else {
            return Container();
          }
        });
  }
}
