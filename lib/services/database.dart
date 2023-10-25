import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/username.dart';
import '../models/user.dart';
//import '../models/userprofile.dart';
//import '../models/ImagePage.dart';

class DatabaseService {
  final String uid;
  final String docId;
  DatabaseService({this.uid, this.docId});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('usernames');

  // final firestoreInstance = FirebaseFirestore.instance;

  DocumentSnapshot _currentDocument;

  Future uploadUserInfo(userMap) async {
    print(userMap);
    return await userCollection.doc(uid).set(userMap);
  }

  List<Username> _usernameListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Username(
        name: doc.data()['name'] ?? '',
        //bio: doc.data()['bio'] ?? '',
        //profileImg: doc.data()['profileImg'] ?? '',
        //name: doc.data()['name'] ?? '',
      );
    }).toList();
  }

  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot.data()['name'],
      email: snapshot.data()['email'],
      imageUrl: snapshot.data()['imageUrl'],
    );
  }

  Stream<List<Username>> get usernames {
    return userCollection.snapshots().map(_usernameListFromSnapshot);
  }

  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  getUserByUsername(String username) async {
    print('userByUsername printed');
    return await userCollection
        .where('userNameIndex', arrayContains: username)
        .get();
  }

  getUserByUserEmail(String email) async {
    return userCollection
        .where(
          'email',
          isEqualTo: email,
        )
        .get();
  }

  Stream<DocumentSnapshot> getUserProfile() {
    return userCollection.doc(uid).snapshots();
  }

  updateUserCollection(updateMap) async {
    return userCollection.doc(uid).update(updateMap);
  }

  addFollowerList(String followerUID, followMap) async {
    return userCollection
        .doc(uid)
        .collection('follower')
        .doc(followerUID)
        .set(followMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<bool> getUserFollower(String followerName) async {
    try {
      var result = await userCollection
          .doc(uid)
          .collection('follower')
          .doc(followerName)
          .get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> getUserFollowing(String followingName) async {
    try {
      var result = await userCollection
          .doc(uid)
          .collection('following')
          .doc(followingName)
          .get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  deleteFollower(String followerUID) async {
    return await userCollection
        .doc(uid)
        .collection('follower')
        .doc(followerUID)
        .delete();
  }

  addFollowingList(String followingUID, followMap) async {
    return userCollection
        .doc(uid)
        .collection('following')
        .doc(followingUID)
        .set(followMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  deleteFollowing(String followingUID) async {
    return await userCollection
        .doc(uid)
        .collection('following')
        .doc(followingUID)
        .delete();
  }

  /*updateFollowers(updateFollower, followerUid) async {
    return userCollection
        .doc(uid)
        .collection('follower')
        .where('followerUid', isEqualTo: followerUid)
        .update();
  }*/

  Future<int> countFollowerDocuments() async {
    var fDoc = await userCollection.doc(uid).collection('follower').get();
    return fDoc.docs.length;
  }

  Future<int> countFollowingDocuments() async {
    var fDoc = await userCollection.doc(uid).collection('following').get();
    return fDoc.docs.length;
  }

  getUserFollowers() {
    print('userByUsername printed');
    return userCollection.doc(uid).collection('follower').snapshots();
  }

  queryUserFollowers(String followerUID) async {
    print('userByUsername printed');
    return await userCollection.where('uid', isEqualTo: followerUID).get();
  }

  getUserFollowings() {
    print('userByUsername printed');
    return userCollection.doc(uid).collection('following').snapshots();
  }

  queryUserFollowings(String followingUID) async {
    print('userByUsername printed');
    return await userCollection.where('uid', isEqualTo: followingUID).get();
  }

  //for videos
  final CollectionReference videoCollection =
      FirebaseFirestore.instance.collection('videos');
  // final firestoreInstance = FirebaseFirestore.instance;
  String id =
      FirebaseFirestore.instance.collection('videos').doc().id.toString();

  Future uploadUserVideos(videoMap) async {
    print(videoMap);
    return await videoCollection.doc(uid).set(videoMap);
  }

  getForYouVideos() {
    return videoCollection.snapshots();
  }

  getFollowingVideos(String followingUsersUid) async {
    return await videoCollection
        .where('uid', isEqualTo: followingUsersUid)
        .get();
  }

  queryForYouVideos(String forYouVideos) async {
    return await userCollection.where('uid', isEqualTo: forYouVideos).get();
  }

  // for likes
  Future likeVideo(likeMap, userUid) async {
    return await videoCollection
        .doc(uid)
        .collection('likes')
        .doc(userUid)
        .set(likeMap);
  }

  Future<bool> getUserLikes(String likeName) async {
    try {
      var result = await videoCollection
          .doc(uid)
          .collection('likes')
          .doc(likeName)
          .get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<int> countLikeDocuments() async {
    var lDoc = await videoCollection.doc(uid).collection('likes').get();
    return lDoc.docs.length;
  }

  deleteUserLikes(String likeName) async {
    return await videoCollection
        .doc(uid)
        .collection('likes')
        .doc(likeName)
        .delete();
  }

  //for comments

  String commentId =
      FirebaseFirestore.instance.collection('comments').doc().id.toString();

  Future commentVideo(commentMap, docRef) async {
    return await docRef.set(commentMap);
  }

  Future likeComment(likeCommentMap, String userUid) async {
    return await videoCollection
        .doc(uid)
        .collection('comments')
        .doc(docId)
        .collection('likes')
        .doc(userUid)
        .set(likeCommentMap);
  }

  deleteLikeComment(String userUid) async {
    return await videoCollection
        .doc(uid)
        .collection('comments')
        .doc(docId)
        .collection('likes')
        .doc(userUid)
        .delete();
  }

  Future<bool> getLikeComment(String userUid) async {
    try {
      var result = await videoCollection
          .doc(uid)
          .collection('comments')
          .doc(docId)
          .collection('likes')
          .doc(userUid)
          .get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<int> countLikeComment() async {
    var result = await videoCollection
        .doc(uid)
        .collection('comments')
        .doc(docId)
        .collection('likes')
        .get();
    return result.docs.length;
  }

  deleteComment() async {
    return await videoCollection
        .doc(uid)
        .collection('comments')
        .doc(docId)
        .delete();
  }

  getComments() {
    return videoCollection.doc(uid).collection('comments').snapshots();
  }

  queryComments(String userCommentUid) async {
    return await userCollection.where('uid', isEqualTo: userCommentUid).get();
  }

  Future<int> countCommentDocuments() async {
    var cDoc = await videoCollection.doc(uid).collection('comments').get();
    return cDoc.docs.length;
  }

  //for chat
  String chatId =
      FirebaseFirestore.instance.collection('chat').doc().id.toString();
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chatRoom');

  createChatRoom(chatRoomId, chatRoomMap) async {
    chatCollection.doc(chatRoomId).set(chatRoomMap);
  }

  Future addConversationMessages(messageMap, docRef) async {
    /*DocumentReference documentReference =
        chatCollection.doc(uid).collection('chat').doc();*/
    return await docRef.set(messageMap).catchError((e) {
      print(e.toString());
    });
  }

  Future likeMessage(likeMessageMap, String userUid) async {
    return await chatCollection
        .doc(uid)
        .collection('chat')
        .doc(docId)
        .collection('likes')
        .doc(userUid)
        .set(likeMessageMap);
  }

  deleteLikeMessage(String userUid) async {
    return await chatCollection
        .doc(uid)
        .collection('chat')
        .doc(docId)
        .collection('likes')
        .doc(userUid)
        .delete();
  }

  Future<bool> getLikeMessage(String userUid) async {
    try {
      var result = await chatCollection
          .doc(uid)
          .collection('chat')
          .doc(docId)
          .collection('likes')
          .doc(userUid)
          .get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<int> countLikeMessage() async {
    var result = await chatCollection
        .doc(uid)
        .collection('chat')
        .doc(docId)
        .collection('likes')
        .get();
    return result.docs.length;
  }

  getMessageLikes() async {
    return chatCollection
        .doc(uid)
        .collection('chat')
        .doc(docId)
        .collection('likes')
        .get();
  }

  querylikes(String likedUid) async {
    return await userCollection.where('uid', isEqualTo: likedUid).get();
  }

  deleteConversationMessage() async {
    return await chatCollection.doc(uid).collection('chat').doc(docId).delete();
  }

  getConversationMessages(String chatRoomId) async {
    return chatCollection
        .doc(chatRoomId)
        .collection('chat')
        .orderBy('time', descending: false)
        .snapshots();
  }

  getChatRooms(String userName) async {
    return await chatCollection
        .where('users', arrayContains: userName)
        .snapshots();
  }

  // for profile post
  getProfilePosts(String userUid) async {
    return await videoCollection.where('uid', isEqualTo: userUid).get();
  }

  // notifications user tokens
  Future saveUserTokens(tokenMap, String docRef) async {
    return await userCollection
        .doc(uid)
        .collection('tokens')
        .doc(docRef)
        .set(tokenMap);
  }

  getNotifications() {
    return userCollection
        .doc(uid)
        .collection('notifications')
        .orderBy('time', descending: true)
        .snapshots();
  }
}
