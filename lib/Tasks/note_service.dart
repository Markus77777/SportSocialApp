import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_app1/Tasks/task_model.dart';
import 'package:flutter/widgets.dart';

class NoteService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> addNote(String subtitle, String type, int image, DateTime? startTime, DateTime? endTime) async {
    try {
      var uuid = const Uuid().v4();
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .set({
        'id': uuid,
        'subtitle': subtitle,
        'type': type,
        'startTime': startTime != null ? Timestamp.fromDate(startTime) : null,
        'endTime': endTime != null ? Timestamp.fromDate(endTime) : null,
        'isDon': false,
        'image': image,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  List<Note> getNotes(AsyncSnapshot snapshot) {
    try {
      return snapshot.data!.docs.map<Note>((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Note(
          data['id'],
          data['subtitle'],
          data['startTime'] != null ? (data['startTime'] as Timestamp).toDate() : null,
          data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
          data['image'],
          data['type'],
          data['isDon'],
        );
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

Stream<QuerySnapshot> streamNotes(bool isDone) {
  return _firebaseFirestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('notes')
      .where('isDon', isEqualTo: isDone)
      .orderBy('endTime', descending: true) 
      .snapshots();
}

  Future<bool> setDoneStatus(String uuid, bool isDon) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .update({'isDon': isDon});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateNote(String uuid, int image, String type, String subtitle, DateTime? startTime, DateTime? endTime) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .update({
        'startTime': startTime != null ? Timestamp.fromDate(startTime) : null,
        'endTime': endTime != null ? Timestamp.fromDate(endTime) : null,
        'subtitle': subtitle,
        'type': type,
        'image': image,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteNote(String uuid) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}