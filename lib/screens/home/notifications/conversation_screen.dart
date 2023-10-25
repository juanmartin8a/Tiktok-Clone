import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiktokClone/screens/home/notifications/conversation_tile.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import '../../../services/helper/constants.dart';
import '../../../models/username.dart';

class ConversationScreen extends StatefulWidget {
  final String myName;
  final String chatRoomId;
  final String userName;
  final String myProPic;
  final String proPic;
  final String myUid;
  ConversationScreen(
      {this.myName,
      this.chatRoomId,
      this.userName,
      this.myProPic,
      this.proPic,
      this.myUid});
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseService databaseService = DatabaseService();
  TextEditingController messageController = TextEditingController();
  final String chatId = DatabaseService().chatId;

  Stream chatMessagesStream;

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(widget.chatRoomId)
          .collection('chat')
          .doc();
      Map<String, dynamic> messageMap = {
        'message': messageController.text,
        'sendBy': widget.myUid,
        'time': DateTime.now().millisecondsSinceEpoch,
        'id': docRef.id
      };
      DatabaseService(uid: widget.chatRoomId)
          .addConversationMessages(messageMap, docRef);
      setState(() {
        messageController.text = '';
      });
    }
  }

  chatMessagesList(BuildContext context, String myUid) {
    return StreamBuilder(
        stream: chatMessagesStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      message: snapshot.data.docs[index].data()['message'],
                      isSendByMe:
                          snapshot.data.docs[index].data()['sendBy'] == myUid,
                      //userUids: snapshot.data.docs[index].data()['sendBy'],
                      myProPic: widget.myProPic,
                      proPic: widget.proPic,
                      chatRoomId: widget.chatRoomId,
                      messageId: snapshot.data.docs[index].data()['id'],
                    );
                  })
              : Container();
        });
  }

  @override
  void initState() {
    DatabaseService().getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessagesStream = value;
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
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
          title: Text(widget.userName,
              style: TextStyle(
                  color: Colors.black, fontSize: 18, letterSpacing: 0.68)),
          centerTitle: true,
        ),
        body: Container(
            child: Stack(
          children: [
            chatMessagesList(context, widget.myUid),
            Container(
              alignment: Alignment.bottomCenter,
              constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                        top: BorderSide(
                      color: Colors.grey[600],
                      width: 0.2,
                    )),
                  ),
                  height: 50,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextField(
                              controller: messageController,
                              decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hintText: 'Send message...',
                              )),
                        ),
                        Expanded(
                            flex: 1,
                            child: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () {
                                  sendMessage();
                                })),
                      ],
                    )
                  ])),
            )
          ],
        )));
  }
}
