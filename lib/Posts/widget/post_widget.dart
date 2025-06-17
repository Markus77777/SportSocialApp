import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Firebase/firebase_service/firestor.dart';
import 'package:flutter_app1/util/image_cached.dart';
import 'package:flutter_app1/Posts/widget/comment.dart';
import 'package:flutter_app1/Posts/widget/like_animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app1/Users/screen/profile_screen.dart';
import 'package:flutter_app1/Posts/widget/likelist.dart';

class PostWidget extends StatefulWidget {
  final snapshot;
  PostWidget(this.snapshot, {super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  bool isAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375.w,
          height: 54.h,
          color: Colors.white,
          child: Center(
            child: ListTile(
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                        Uid: widget.snapshot['uid']), 
                  ));
                },
                child: ClipOval(
                  child: SizedBox(
                    width: 35.w,
                    height: 35.h,
                    child: CachedImage(widget.snapshot['profileImage']),
                  ),
                ),
              ),
              title: GestureDetector(      
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                        Uid: widget.snapshot['uid']),
                  ));
                },
                child: Text(
                  widget.snapshot['username'],
                  style: TextStyle(fontSize: 19.sp, color: Colors.black),
                ),
              ),
              subtitle: Text(
                widget.snapshot['location'],
                style: TextStyle(fontSize: 11.sp),
              ),
              trailing: (FirebaseAuth.instance.currentUser!.uid == widget.snapshot['uid'])
    ? PopupMenuButton<String>(
        
        
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'delete',
            child: Text('刪除貼文'),
          ),
        ],
        icon: const Icon(Icons.more_horiz),
      )
    : null,
            ),
          ),
        ),
        GestureDetector(
          onDoubleTap: () {
            Firebase_Firestor().like(
                like: widget.snapshot['like'],
                type: 'posts',
                uid: user,
                postId: widget.snapshot['postId']);
            setState(() {
              isAnimating = true;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 375.w,
                height: 375.h,
                child: CachedImage(
                  widget.snapshot['postImage'],
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: isAnimating ? 1 : 0,
                child: LikeAnimation(
                  child: Icon(
                    Icons.favorite,
                    size: 100.w,
                    color: Colors.red,
                  ),
                  isAnimating: isAnimating,
                  duration: Duration(milliseconds: 400),
                  iconlike: false,
                  End: () {
                    setState(() {
                      isAnimating = false;
                    });
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          width: 375.w,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.h),
              Row(
                children: [
                  SizedBox(width: 14.w),
                  LikeAnimation(
                    child: IconButton(
                      onPressed: () {
                        Firebase_Firestor().like(
                          like: widget.snapshot['like'],
                          type: 'posts',
                          uid: user,
                          postId: widget.snapshot['postId'],
                        );
                      },
                      icon: Icon(
                        widget.snapshot['like'].contains(user)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.snapshot['like'].contains(user)
                            ? Colors.red
                            : Colors.black,
                        size: 24.w,
                      ),
                    ),
                    isAnimating: widget.snapshot['like'].contains(user),
                  ),
                  SizedBox(width: 4.w),
                  //like數量連結到likelist
                  GestureDetector(
                    onTap: () {
                      showBottomSheet(
                        backgroundColor:Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: DraggableScrollableSheet(
                              maxChildSize: 0.6,
                              initialChildSize: 0.6,
                              minChildSize: 0.2,
                              builder: (context, scrollController) {
                                return LikeList(
                                    widget.snapshot['postId']); // 顯示 LikeList
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      widget.snapshot['like'].length.toString(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 17.w),
                  //comment
                  GestureDetector(
                    onTap: () {
                      showBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: DraggableScrollableSheet(
                              maxChildSize: 0.6,
                              initialChildSize: 0.6,
                              minChildSize: 0.2,
                              builder: (context, scrollController) {
                                return Comment(
                                  'posts',
                                  widget.snapshot['postId'],
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Image.asset(
                      'images/comment.webp',
                      height: 28.h,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.snapshot['postId'])
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          '0',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return Text(
                        snapshot.data!.docs.length.toString(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.snapshot['username'] +
                            ' :  ' +
                            widget.snapshot['caption'],
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.w, top: 0.h, bottom: 8.h),
                child: Text(
                  formatDate(widget.snapshot['time'].toDate(),
                      [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]),
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color.fromARGB(255, 57, 50, 50)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
