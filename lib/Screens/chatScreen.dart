import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../Colors.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: ChatUserList(),
    );
  }
}

class ChatUserList extends StatefulWidget {
  @override
  _ChatUserListState createState() => _ChatUserListState();
}

class _ChatUserListState extends State<ChatUserList> {
  String currentUserShareId = '';

  @override
  void initState() {
    super.initState();
    getCurrentUserShareId();
  }

  Future<void> getCurrentUserShareId() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          currentUserShareId = snapshot.data()['share_id'] ?? '';
        });
      }
    } catch (e) {
      print('Error getting current user share_id: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .where('share_id', isEqualTo: currentUserShareId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data();
            final userId = users[index].id;
            // Exclude the current user from the list
            if (userId != FirebaseAuth.instance.currentUser?.uid) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc('${userId}_${FirebaseAuth.instance.currentUser?.uid}')
                    .collection('messages')
                    .where('isRead', isEqualTo: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> unreadSnapshot) {
                  if (!unreadSnapshot.hasData) {
                    return SizedBox();
                  }
                  final unreadCount = unreadSnapshot.data.docs.length;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoom(
                            otherUserId: userId,
                            otherUserName: userData['username'],
                            otherUserAvatar: userData['avatar'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12.0),
                                bottomRight: Radius.circular(12.0),
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: teal,
                              backgroundImage: userData['avatar'] != null
                                  ? NetworkImage(userData['avatar'])
                                  : AssetImage('images/doctoravatar.png'),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData['username'] ?? 'Anonymous',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(userData['email'] ?? ''),
                                ],
                              ),
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.deepOrangeAccent,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          SizedBox(width: 10),
                          // Container(
                          //   width: 10,
                          //   height: 10,
                          //   margin: EdgeInsets.only(right: 15),
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     color: userData['online'] == true
                          //         ? Colors.green
                          //         : Colors.red,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return SizedBox(); // Exclude the current user from the list
            }
          },
        );
      },
    );
  }
}

class ChatRoom extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  ChatRoom({this.otherUserId, this.otherUserName, this.otherUserAvatar});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController _messageController = TextEditingController();
  bool _isRead = false;

  @override
  void initState() {
    super.initState();
    markMessagesAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: teal,
              backgroundImage: widget.otherUserAvatar != null
                  ? NetworkImage(widget.otherUserAvatar)
                  : AssetImage('images/doctoravatar.png'),
            ),
            SizedBox(width: 10),
            Text(widget.otherUserName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc('${FirebaseAuth.instance.currentUser?.uid}_${widget.otherUserId}')
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    bool isMe = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message['isFile'] ?? false)
                              Image.network(
                                message['text'],
                                width: 150,
                                height: 150,
                              ),
                            if (!(message['isFile'] ?? false))
                              Text(
                                message['text'],
                                style: TextStyle(fontSize: 16),
                              ),
                            SizedBox(height: 5),
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(int.parse(message['timestamp']))
                                  .toString(),
                              style: TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                            if (isMe && message['isRead'])
                              Icon(
                                Icons.done_all,
                                color: teal,
                                size: 16,
                              )
                            else if (isMe)
                              Icon(
                                Icons.done,
                                color: Colors.grey,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: teal),
                  onPressed: pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: teal),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: teal),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: teal),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void markMessagesAsRead() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      QuerySnapshot unreadMessages = await FirebaseFirestore.instance
          .collection('chats')
          .doc('${widget.otherUserId}_$currentUserId')
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .get();

      for (DocumentSnapshot message in unreadMessages.docs) {
        await message.reference.update({'isRead': true});
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      String otherUserId = widget.otherUserId;
      String messageText = _messageController.text;

      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc('${currentUserId}_$otherUserId')
            .collection('messages')
            .add({
          'senderId': currentUserId,
          'text': messageText,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'isRead': false,
          'isFile': false,
        });

        await FirebaseFirestore.instance
            .collection('chats')
            .doc('${otherUserId}_$currentUserId')
            .collection('messages')
            .add({
          'senderId': currentUserId,
          'text': messageText,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'isRead': false,
          'isFile': false,
        });

        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  void pickFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;

      // Upload file to Firebase Storage
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('chat_files')
          .child(fileName)
          .putFile(File(file.path));

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      String fileUrl = await taskSnapshot.ref.getDownloadURL();

      // Send file message
      sendMessageWithFile(fileUrl);
    } else {
      // User canceled the picker
    }
  }

  void sendMessageWithFile(String fileUrl) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    String otherUserId = widget.otherUserId;

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc('${currentUserId}_$otherUserId')
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'text': fileUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'isRead': false,
        'isFile': true,
      });

      await FirebaseFirestore.instance
          .collection('chats')
          .doc('${otherUserId}_$currentUserId')
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'text': fileUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'isRead': false,
        'isFile': true,
      });
    } catch (e) {
      print('Error sending file: $e');
    }
  }
}
