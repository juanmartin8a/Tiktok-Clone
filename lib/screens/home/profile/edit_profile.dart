import 'package:flutter/material.dart';
import 'package:tiktokClone/models/user.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/username.dart';

class EditProfile extends StatefulWidget {
  final String name;
  final String bio;
  final String profileImg;
  EditProfile({this.name, this.bio, this.profileImg});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File _imageFile;
  DatabaseService databaseService = DatabaseService();

  final _formKey = GlobalKey<FormState>();
  TextEditingController name;
  TextEditingController bio;

  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://tiktokclone-d496a.appspot.com');
  StorageUploadTask _uploadTask;
  StorageTaskSnapshot _taskSnapshot;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final selected = await ImagePicker().getImage(source: source);

    setState(() {
      _imageFile = File(selected.path);
      _cropImage();
    });
  }

  _startUpload(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    if (_imageFile != null) {
      String filePath = 'images/${user.uid}.png';
      _uploadTask = _storage.ref().child(filePath).putFile(_imageFile);
      _taskSnapshot = await _uploadTask.onComplete;
      //if (_taskSnapshot.error == null) {
      final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
      List<String> splitList = name.text.split(" ");
      List<String> indexList = [];
      for (int i = 0; i < splitList.length; i++) {
        for (int y = 1; y < splitList[i].length + 1; y++) {
          indexList.add(splitList[i].substring(0, y).toLowerCase());
        }
      }
      print(indexList);
      Map<String, dynamic> userMap = {
        'profileImg': downloadUrl ?? widget.profileImg,
        'bio': bio.text,
        'name': name.text,
        'userNameIndex': indexList,
      };
      HelperFunctions.saveUserNameSharedPreference(name.text);
      print('My new name is ${Constants.myName}');
      DatabaseService(uid: user.uid).updateUserCollection(userMap);
    } else if (_imageFile == null) {
      List<String> splitList = name.text.split(" ");
      List<String> indexList = [];
      for (int i = 0; i < splitList.length; i++) {
        for (int y = 1; y < splitList[i].length + 1; y++) {
          indexList.add(splitList[i].substring(0, y).toLowerCase());
        }
      }
      print(indexList);
      Map<String, dynamic> userMap = {
        'profileImg': widget.profileImg,
        'bio': bio.text,
        'name': name.text,
        'userNameIndex': indexList,
      };
      await HelperFunctions.saveUserNameSharedPreference(name.text);
      print('My new name is ${Constants.myName}');
      DatabaseService(uid: user.uid).updateUserCollection(userMap);
    }

    //}
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      cropStyle: CropStyle.circle,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: Colors.purple,
        toolbarWidgetColor: Colors.white,
        toolbarTitle: 'Crop It',
      ),
    );
    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void _clear() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    name.text = widget.name;
    name.addListener(() {
      print(name.text);
    });
    bio = TextEditingController();
    bio.text = widget.bio;
    bio.addListener(() {
      print(bio.text);
    });
  }

  _showCustomBottomSheet(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                  height: 200,
                  width: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey[700],
                                          width: 0.2))),
                              alignment: Alignment.center,
                              child: Text('Change Profile Picture',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.bold)))),
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey[700], width: 0.2),
                                      top: BorderSide(
                                          color: Colors.grey[700],
                                          width: 0.2))),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                  onTap: () {
                                    _pickImage(context, ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Take Photo',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16, letterSpacing: 0.8))))),
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey[700], width: 0.2),
                                      top: BorderSide(
                                          color: Colors.grey[700],
                                          width: 0.2))),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                  onTap: () {
                                    _pickImage(context, ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Choose from Library',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16, letterSpacing: 0.8))))),
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Colors.grey[700],
                                          width: 0.2))),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 0.8,
                                          color: Colors.red))))),
                    ],
                  )));
        });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
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
          title: Text('Edit profile',
              style: TextStyle(
                  color: Colors.black, fontSize: 18, letterSpacing: 0.68)),
          centerTitle: true,
          actions: [
            Container(
                child: MaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                    child: Text('Save',
                        style: TextStyle(fontSize: 16, color: Colors.pink)),
                    onPressed: () {
                      _startUpload(context);
                      print('my new new name is ${Constants.myName}');
                      Navigator.pop(context);
                    }))
          ],
        ),
        body: Container(
            child: Form(
          key: _formKey,
          child: Container(
              padding: EdgeInsets.only(top: 20),
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      child: GestureDetector(
                          onTap: () {
                            _showCustomBottomSheet(context);
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _imageFile == null
                                ? NetworkImage(widget.profileImg)
                                : FileImage(
                                    _imageFile,
                                  ),
                            backgroundColor: Colors.grey[300],
                          ))),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('name:',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  letterSpacing: .8,
                                  fontSize: 14)),
                        ),
                        Expanded(
                            flex: 10,
                            child: TextFormField(
                              controller: name,
                              decoration: InputDecoration(
                                isDense: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400]),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 4),
                              ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 28),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('bio:',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  letterSpacing: .8,
                                  fontSize: 14)),
                        ),
                        Expanded(
                            flex: 10,
                            child: TextFormField(
                              controller: bio,
                              decoration: InputDecoration(
                                isDense: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[400]),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 4),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              )),
        )));
  }
}
