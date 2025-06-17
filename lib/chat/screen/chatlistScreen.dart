import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app1/chat/firestorechat.dart';
import 'package:flutter_app1/Users/screen/profile_screen.dart';
import 'package:flutter_app1/chat/screen/chatroomScreen.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('users', arrayContains: currentUid)
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                '尚無聊天對象',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final users = List<String>.from(chat['users']);
              final otherUid = users.firstWhere((uid) => uid != currentUid);

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUid).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text('載入中...'));
                  }

                  final user = userSnapshot.data!;
                  final lastTime = (chat['lastTimestamp'] as Timestamp).toDate();
                  final timeStr = DateFormat('HH:mm').format(lastTime);

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(user['profile'] ?? ''),
                    ),
                    title: Text(
                      user['username'] ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      chat['lastMessage'] ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      timeStr,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          currentUserId: currentUid,
                          otherUserId: otherUid,
                          otherUsername: user['username'],
                          otherProfile: user['profile'],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}