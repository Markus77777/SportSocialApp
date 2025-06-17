import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app1/Firebase/model/usermodel.dart';
import 'package:flutter_app1/util/exeption.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_app1/Tasks/note_service.dart'; 

class Firebase_Firestor {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> CreateUser({
    required String email,
    required String username,
    required String bio,
    required String profile,
  }) async {
    await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'email': email,
      'username': username,
      'bio': bio,
      'profile': profile,
      'followers': [],
      'following': [],
    });
    return true;
  }

  Future<Usermodel> getUser({String? UID}) async {
    try {
      final user = await _firebaseFirestore
          .collection('users')
          .doc(UID != null ? UID : _auth.currentUser!.uid)
          .get();
      final snapuser = user.data()!;
      return Usermodel(
          snapuser['bio'],
          snapuser['email'],
          snapuser['followers'],
          snapuser['following'],
          snapuser['profile'],
          snapuser['username']);
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<void> updateProfile({
    required String username,
    required String bio,
    required String profile,
  }) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({
        'username': username,
        'bio': bio,
        'profile': profile,
      });
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<bool> CreatePost({
    required String postImage,
    required String caption,
    required String location,
  }) async {
    var uid = Uuid().v4();
    DateTime data = DateTime.now();
    Usermodel user = await getUser();
    await _firebaseFirestore.collection('posts').doc(uid).set({
      'postImage': postImage,
      'username': user.username,
      'profileImage': user.profile,
      'caption': caption,
      'location': location,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }

  Future<bool> CreatReels({
    required String video,
    required String caption,
  }) async {
    var uid = Uuid().v4();
    DateTime data = DateTime.now();
    Usermodel user = await getUser();
    await _firebaseFirestore.collection('reels').doc(uid).set({
      'reelsvideo': video,
      'username': user.username,
      'profileImage': user.profile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }
Future<bool> Comments({
  required String comment,
  required String type,
  required String uidd,
}) async {
  var uid = Uuid().v4();
  DateTime data = DateTime.now();
  Usermodel user = await getUser();

  // 儲存留言資料
  await _firebaseFirestore
      .collection(type)
      .doc(uidd)
      .collection('comments')
      .doc(uid)
      .set({
    'comment': comment,
    'username': user.username,
    'uid': _auth.currentUser!.uid,
    'profileImage': user.profile,
    'CommentUid': uid,
    'time': data,
  });

  //  發送通知
  final postDoc = await _firebaseFirestore.collection(type).doc(uidd).get();
  final receiverId = postDoc['uid']; // 貼文擁有者

  if (receiverId != _auth.currentUser!.uid) {
    await _firebaseFirestore
        .collection('users')
        .doc(receiverId)
        .collection('notifications')
        .add({
      'type': 'comment',
      'senderId': _auth.currentUser!.uid,
      'senderUsername': user.username,
      'senderProfile': user.profile,
      'postId': uidd,
      'message': '${user.username} 留言了你的貼文',
      'isRead': false,
      'timestamp': data,
    });
  }

  return true;
}


Future<String> like({
  required List like,
  required String type,
  required String uid,
  required String postId,
}) async {
  String res = 'some error';
  try {
    final currentUser = await getUser(); // 取得按讚者的用戶資訊

    final postDoc = await _firebaseFirestore.collection(type).doc(postId).get();
    final receiverId = postDoc['uid']; // 取得貼文的作者UID

    if (like.contains(uid)) {
      // 取消按讚
      await _firebaseFirestore.collection(type).doc(postId).update({
        'like': FieldValue.arrayRemove([uid])
      });
    } else {
      // 新增按讚
      await _firebaseFirestore.collection(type).doc(postId).update({
        'like': FieldValue.arrayUnion([uid])
      });

      //  發送通知（避免自己按自己的貼文）
      if (receiverId != uid) {
        await _firebaseFirestore
            .collection('users')
            .doc(receiverId)
            .collection('notifications')
            .add({
          'type': 'like',
          'senderId': uid,
          'senderUsername': currentUser.username,
          'senderProfile': currentUser.profile,
          'postId': postId,
          'message': '${currentUser.username} 按讚了你的貼文',
          'isRead': false,
          'timestamp': DateTime.now(),
        });
      }
    }

    res = 'success';
  } catch (e) {
    res = e.toString();
  }

  return res;
}


Future<void> flollow({
  required String uid, // 被追蹤者的 UID
}) async {
  try {
    DocumentSnapshot snap = await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();

    List following = (snap.data()! as dynamic)['following'];

    if (following.contains(uid)) {
      // 取消追蹤
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({
        'following': FieldValue.arrayRemove([uid])
      });

      await _firebaseFirestore.collection('users').doc(uid).update({
        'followers': FieldValue.arrayRemove([_auth.currentUser!.uid])
      });
    } else {
      // 新增追蹤
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({
        'following': FieldValue.arrayUnion([uid])
      });

      await _firebaseFirestore.collection('users').doc(uid).update({
        'followers': FieldValue.arrayUnion([_auth.currentUser!.uid])
      });

      // 新增通知
      if (_auth.currentUser!.uid != uid) {
        final sender = await getUser(); // 拿目前登入者資訊

        await _firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .add({
          'type': 'follow',
          'senderId': _auth.currentUser!.uid,
          'senderUsername': sender.username,
          'senderProfile': sender.profile,
          'message': '${sender.username} 開始追蹤你了',
          'isRead': false,
          'timestamp': DateTime.now(),
        });
      }
    }
  } on Exception catch (e) {
    print(e.toString());
  }
}

}
