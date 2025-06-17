import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Users/screen/profile_screen.dart';
import 'package:flutter_app1/util/image_cached.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FollowersList extends StatelessWidget {
  final String uid;
  FollowersList(this.uid, {super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!;
          List<dynamic> followers = userData['followers'];

          if (followers.isEmpty) {
            return Center(child: Text('No followers.'));
          }

          return ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) {
              return followerItem(followers[index]);
            },
          );
        },
      ),
    );
  }

  Widget followerItem(String followerUid) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(followerUid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var userData = snapshot.data!;
        return ListTile(
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(Uid: followerUid),
              ));
            },
            child: ClipOval(
              child: SizedBox(
                height: 35.h,
                width: 35.w,
                child: CachedImage(userData['profile']),
              ),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(Uid: followerUid),
              ));
            },
            child: Text(
              userData['username'],
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
