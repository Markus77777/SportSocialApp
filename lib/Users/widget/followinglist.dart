import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Users/screen/profile_screen.dart';
import 'package:flutter_app1/util/image_cached.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FollowingList extends StatelessWidget {
  final String uid;
  FollowingList(this.uid, {super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!;
          List<dynamic> following = userData['following'];

          if (following.isEmpty) {
            return Center(child: Text('Not following anyone.'));
          }

          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              return followingItem(following[index]);
            },
          );
        },
      ),
    );
  }

  Widget followingItem(String followingUid) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(followingUid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var userData = snapshot.data!;
        return ListTile(
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(Uid: followingUid),
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
                builder: (context) => ProfileScreen(Uid: followingUid),
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
