import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/auth/mainpage.dart';
import 'package:flutter_app1/Firebase/firebase_service/firestor.dart';
import 'package:flutter_app1/Firebase/model/usermodel.dart';
import 'package:flutter_app1/Posts/screen/post_screen.dart';
import 'package:flutter_app1/Users/screen/editprofile.dart';
import 'package:flutter_app1/util/image_cached.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app1/Users/widget/button.dart';
import 'package:flutter_app1/Firebase/firebase_service/firebase_auth.dart';
import 'package:flutter_app1/Users/widget/followerslist.dart';
import 'package:flutter_app1/Users/widget/followinglist.dart';
import 'package:flutter_app1/chat/screen/chatroomScreen.dart';

class ProfileScreen extends StatefulWidget {
  final String Uid;
  ProfileScreen({super.key, required this.Uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int post_lenght = 0;
  bool yourse = false;
  List following = [];
  bool follow = false;

  @override
  void initState() {
    super.initState();
    getdata();
    if (widget.Uid == _auth.currentUser!.uid) {
      setState(() {
        yourse = true;
      });
    }
  }

  getdata() async {
    DocumentSnapshot snap = await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    following = (snap.data()! as dynamic)['following'];
    if (following.contains(widget.Uid)) {
      setState(() {
        follow = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(); // 返回上一頁
            },
          ),
        ),
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder(
                  future: Firebase_Firestor().getUser(UID: widget.Uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Head(snapshot.data!);
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 5.h,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 30.h,
                  child: const TabBar(
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.video_collection)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 400.h, 
                  child: TabBarView(
                    children: [
                      StreamBuilder(
                        stream: _firebaseFirestore
                            .collection('posts')
                            .where('uid', isEqualTo: widget.Uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          post_lenght = snapshot.data!.docs.length;
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemCount: post_lenght,
                            itemBuilder: (context, index) {
                              final snap = snapshot.data!.docs[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          PostScreen(snap.data())));
                                },
                                child: CachedImage(
                                  snap['postImage'],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Center(child: Text('尚未完成')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Head(Usermodel user) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
                child: ClipOval(
                  child: SizedBox(
                    width: 85.w,
                    height: 85.h,
                    child: CachedImage(user.profile),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 20.w),
                      Text(
                        post_lenght.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 70.w),
                      Text(
                        user.followers.length.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 80.w),
                      Text(
                        user.following.length.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 3.w),
                      Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 17.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                FollowersList(widget.Uid), // 顯示跟隨者列表
                          ));
                        },
                        child: Text(
                          'Followers',
                          style: TextStyle(
                            fontSize: 17.sp, 
                            fontWeight: FontWeight.bold, 
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                FollowingList(widget.Uid), // 顯示跟隨的列表
                          ));
                        },
                        child: Text(
                          'Following',
                          style: TextStyle(
                            fontSize: 17.sp, 
                            fontWeight: FontWeight.bold, 
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      user.bio,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                MyButton(
                  onTab: () async {
                    await Authentication().SignOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MainPage(),
                      ),
                    );
                  },
                  text: "Log Out",
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Visibility(
            visible: !follow,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: GestureDetector(
                onTap: () {
                  if (!yourse) {
                    Firebase_Firestor().flollow(uid: widget.Uid);
                    setState(() {
                      follow = true;
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 30.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: yourse ? Colors.white : Colors.blue,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(
                        color: yourse ? const Color.fromARGB(255, 189, 189, 189) : Colors.blue),
                  ),
                  child: yourse
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditScreen(),
                              ),
                            );
                          },
                          child: Text('Edit Your Profile',
                              style: TextStyle(color: Colors.black)),
                        )
                      : Text(
                          'Follow',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: follow,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Firebase_Firestor().flollow(uid: widget.Uid);
                        setState(() {
                          follow = false;
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 30.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text('Unfollow')),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            currentUserId: FirebaseAuth.instance.currentUser!.uid,
            otherUserId: widget.Uid,
            otherUsername: user.username,
            otherProfile: user.profile,
          ),
        ),
      );
    },
    child: Container(
      alignment: Alignment.center,
      height: 30.h,
      width: 100.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        'Message',
        style: TextStyle(color: Colors.black),
      ),
    ),
  ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }
}
