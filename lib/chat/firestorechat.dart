import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 發送訊息（僅限雙方互追）
  Future<void> sendMessage({
    required String toUid,
    required String text,
  }) async {
    final currentUid = _auth.currentUser!.uid;

    //  檢查是否互追
    final currentUserSnap =
        await _firestore.collection('users').doc(currentUid).get();
    final targetUserSnap =
        await _firestore.collection('users').doc(toUid).get();

    final currentFollowing = List<String>.from(currentUserSnap['following']);
    final targetFollowing = List<String>.from(targetUserSnap['following']);

    final isMutual = currentFollowing.contains(toUid) &&
                     targetFollowing.contains(currentUid);

    if (!isMutual) {
      return; // 不提示、不儲存
    }

    final chatIdParts = [currentUid, toUid]..sort();
    final chatDocId = chatIdParts.join('_');

    final message = {
      'from': currentUid,
      'to': toUid,
      'text': text,
      'timestamp': Timestamp.now(),
      'read': false, // 初始為未讀
    };

    await _firestore
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .add(message);

    await _firestore.collection('chats').doc(chatDocId).set({
      'users': chatIdParts,
      'lastMessage': text,
      'lastTimestamp': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// 取得聊天室訊息串（可用於 StreamBuilder）
  Stream<QuerySnapshot> getChatMessages(String userA, String userB) {
    final chatIdParts = [userA, userB]..sort();
    final chatDocId = chatIdParts.join('_');

    return _firestore
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// 將所有收件訊息設為已讀
  Future<void> markMessagesAsRead({
    required String fromUid,
    required String toUid,
  }) async {
    final chatIdParts = [fromUid, toUid]..sort();
    final chatDocId = chatIdParts.join('_');

    final messagesRef = _firestore
        .collection('chats')
        .doc(chatDocId)
        .collection('messages');

    final unread = await messagesRef
        .where('to', isEqualTo: fromUid)
        .where('read', isEqualTo: false)
        .get();

    for (final doc in unread.docs) {
      await doc.reference.update({'read': true});
    }
  }
}  
