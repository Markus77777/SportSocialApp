import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Firebase/firebase_service/firestor.dart';
import 'package:flutter_app1/util/image_cached.dart';
import 'package:flutter_app1/Posts/widget/comment.dart';
import 'package:flutter_app1/Posts/widget/like_animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:flutter_app1/Users/screen/profile_screen.dart'; 

class ReelsItem extends StatefulWidget {
  final snapshot;
  ReelsItem(this.snapshot, {super.key});

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> {
  late VideoPlayerController controller;
  bool play = true;
  bool isAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!.uid;
    controller = VideoPlayerController.network(widget.snapshot['reelsvideo'])
      ..initialize().then((value) {
        setState(() {
          controller.setLooping(true);
          controller.setVolume(1);
          controller.play();
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
GestureDetector(
  onDoubleTap: () {
    Firebase_Firestor().like(
      like: widget.snapshot['like'],
      type: 'reels',
      uid: user,
      postId: widget.snapshot['postId'],
    );
    setState(() {
      isAnimating = true;
    });
  },
  onTap: () {
    setState(() {
      play = !play;
    });
    if (play) {
      controller.play();
    } else {
      controller.pause();
    }
  },
  child: SizedBox.expand(
    child: VideoPlayer(controller),
  ),
),

        if (!play)
          Center(
            child: CircleAvatar(
              backgroundColor: Colors.white30,
              radius: 35.r,
              child: Icon(
                Icons.play_arrow,
                size: 35.w,
                color: Colors.white,
              ),
            ),
          ),
        Center(
          child: AnimatedOpacity(
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
          ),
        ),
        Positioned(
          top: 430.h,
          right: 15.w,
          child: Column(
            children: [
              LikeAnimation(
                child: IconButton(
                  onPressed: () {
                    Firebase_Firestor().like(
                      like: widget.snapshot['like'],
                      type: 'reels',
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
                        : Colors.white,
                    size: 24.w,
                  ),
                ),
                isAnimating: widget.snapshot['like'].contains(user),
              ),
              SizedBox(height: 3.h),
              Text(
                widget.snapshot['like'].length.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 15.h),
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
                            return Comment('reels', widget.snapshot['postId']);
                          },
                        ),
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.comment,
                  color: Colors.white,
                  size: 28.w,
                ),
              ),
              SizedBox(height: 3.h),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reels')
                    .doc(widget.snapshot['postId'])
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text(
                      '0',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    );
                  }
                  return Text(
                    snapshot.data!.docs.length.toString(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
        Positioned(
          bottom: 40.h,
          left: 10.w,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(Uid: widget.snapshot['uid']), 
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        height: 35.h,
                        width: 35.w,
                        child: CachedImage(widget.snapshot['profileImage']),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      widget.snapshot['username'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10.w),             
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.snapshot['caption'],
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
