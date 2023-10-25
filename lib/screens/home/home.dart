import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import 'package:tiktokClone/screens/home/main/for_you.dart';
import 'package:tiktokClone/screens/home/search/search.dart';
import 'package:tiktokClone/screens/home/upload/uplaod_vid.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../services/database.dart';
import '../../services/auth.dart';
import '../../services/helper/constants.dart';
import '../../services/helper/helperfunctions.dart';
import 'package:provider/provider.dart';
//import 'unames.dart';
import '../../models/username.dart';
import 'profile/profile.dart';
//import 'profile.dart';
//import 'pageView.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final DatabaseService databaseService = DatabaseService();
  //Stream chatRoomStream;

  bool main = true;
  bool profile = false;
  bool search = false;
  bool upload = false;

  void setProfile() {
    setState(() {
      main = false;
      search = false;
      profile = true;
      upload = false;
    });
  }

  void setSearch() {
    setState(() {
      main = false;
      profile = false;
      search = true;
      upload = false;
    });
  }

  void setMain() {
    setState(() {
      profile = false;
      search = false;
      main = true;
      upload = false;
    });
  }

  void setUpload() {
    setState(() {
      profile = false;
      search = false;
      main = false;
      upload = true;
    });
  }

  _homeContent(BuildContext context) {
    if (main == true &&
        profile == false &&
        search == false &&
        upload == false) {
      return Navigator.push(
          context, MaterialPageRoute(builder: (context) => ForYou()));
    } else if (main == false &&
        profile == true &&
        search == false &&
        upload == false) {
      return StreamProvider<UserData>.value(
          value: DatabaseService().userData, child: Profile());
    } else if (main == false &&
        profile == false &&
        search == true &&
        upload == false) {
      return SearchScreen();
    } else if (main == false &&
        profile == false &&
        search == false &&
        upload == true) {
      return VideoUpload();
    }
  }

  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myEmail = await HelperFunctions.getUserEmailSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    print('current username is ${Constants.myName}');
    return Scaffold(
      appBar: AppBar(
        /*bottom: PreferredSize(
          child: Container(
            color: Colors.black,
            height: 1,
          ),
          preferredSize: Size.fromHeight(4.0)),*/
        //backgroundColor: Colors.white,
        title: Text('Home Screen', style: TextStyle(color: Colors.white)),
        actions: [
          FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () async {
                await _auth.signOut();
              }),
        ],
      ),
      body: Container(
          child: Column(
        children: [
          Expanded(flex: 9, child: _homeContent(context)),
        ],
      )),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //use IconButton to have icons as buttons
          FlatButton(
            child: Text('home'),
            onPressed: () {
              setMain();
              /*Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ForYou()));*/
            }, //setMain(),
          ),
          FlatButton(
            child: Text('search'),
            onPressed: () => setSearch(),
          ),
          FlatButton(
            child: Text('upload'),
            onPressed: () => setUpload(),
          ),
          FlatButton(
            child: Text('profile'),
            onPressed: () => setProfile(),
          ),
        ],
      )),
    );
  }
}
