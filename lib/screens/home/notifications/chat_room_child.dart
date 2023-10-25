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

class ChatRoomTileChild extends StatefulWidget {
  @override
  _ChatRoomTileChildState createState() => _ChatRoomTileChildState();
}

class _ChatRoomTileChildState extends State<ChatRoomTileChild> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
