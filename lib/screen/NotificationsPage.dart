import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_app1/Posts/screen/post_screen.dart';
import 'package:flutter_app1/Users/screen/profile_screen.dart';

class NotificationsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('目前沒有通知'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('刪除通知'),
                      content: const Text('確定要刪除這則通知嗎？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('刪除'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await _firestore
                      .collection('users')
                      .doc(uid)
                      .collection('notifications')
                      .doc(doc.id)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('通知已刪除')),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderProfile']),
                  ),
                  title: Text(data['message']),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(
                      data['timestamp'].toDate(),
                    ),
                  ),
                  trailing: data['isRead']
                      ? const Icon(Icons.check, color: Colors.grey)
                      : const Icon(Icons.new_releases, color: Colors.red),
                  onTap: () async {
                    await _firestore
                        .collection('users')
                        .doc(uid)
                        .collection('notifications')
                        .doc(doc.id)
                        .update({'isRead': true});

                    final type = data['type'];
                    final senderId = data['senderId'];
                    final postId = data['postId'];

                    if (type == 'follow') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(Uid: senderId),
                        ),
                      );
                    } else if (type == 'like' || type == 'comment') {
                      try {
                        final postSnap = await _firestore
                            .collection('posts')
                            .doc(postId)
                            .get();

                        if (postSnap.exists) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostScreen(postSnap),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('貼文已不存在')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('無法載入貼文')),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
