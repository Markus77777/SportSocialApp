import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Firebase/firebase_service/firestor.dart';
import 'package:flutter_app1/util/image_cached.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app1/Users/screen/profile_screen.dart';

class LikeList extends StatefulWidget {
  final String postId; 
  LikeList(this.postId, {super.key});

  @override
  State<LikeList> createState() => _LikeListState();
}

class _LikeListState extends State<LikeList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.r),
        topRight: Radius.circular(25.r),
      ),
      child: Container(
        color: Colors.grey[200], 
        height: 400.h,  
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection('posts')
              .doc(widget.postId)  // 根據 postId 查詢指定的貼文
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var postData = snapshot.data!;
            List<dynamic> likes = postData['like'];  // 取得 like 陣列

            if (likes.isEmpty) {
              return Center(child: Text('No likes yet.', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)));
            }

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: ListView.builder(
                itemCount: likes.length,
                itemBuilder: (context, index) {
                  return likeItem(likes[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget likeItem(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(uid).get(),  // 根據 UID 查詢用戶資料
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var userData = snapshot.data!;
        return ListTile(
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(Uid: uid),
              ));
            },
            child: ClipOval(
              child: SizedBox(
                height: 35.h,
                width: 35.w,
                child: CachedImage(userData['profile'] ?? 'default_profile_image_url'),  
              ),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(Uid: uid),
              ));
            },
            child: Text(
              userData['username'] ?? 'No Username',  
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
