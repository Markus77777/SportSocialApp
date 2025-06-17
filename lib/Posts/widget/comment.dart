import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Firebase/firebase_service/firestor.dart';
import 'package:flutter_app1/util/image_cached.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app1/Users/screen/profile_screen.dart';
class Comment extends StatefulWidget {
  final String type;
  final String uid;
  Comment(this.type, this.uid, {super.key});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.r),
        topRight: Radius.circular(25.r),
      ),
      child: Container(
        color: Colors.white,
        height: 200.h,
        child: Stack(
          children: [
            Positioned(
              top: 8.h,
              left: 140.w,
              child: Container(
                width: 100.w,
                height: 3.h,
                color: Colors.black,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(widget.type)
                  .doc(widget.uid)
                  .collection('comments')
                  .orderBy('time', descending: true) // 根據時間排序，從新到舊
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return commentItem(snapshot.data!.docs[index]);
                    },
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 60.h,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 45.h,
                      width: 260.w,
                      child: TextField(
                        controller: commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isLoading = true;
                        });
                        if (commentController.text.isNotEmpty) {
                          Firebase_Firestor().Comments(
                            comment: commentController.text,
                            type: widget.type,
                            uidd: widget.uid,
                          ).then((_) {
                            setState(() {
                              isLoading = false;
                              commentController.clear();
                            });
                          });
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: isLoading
                          ? SizedBox(
                              width: 10.w,
                              height: 10.h,
                              child: const CircularProgressIndicator(),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget commentItem(DocumentSnapshot snapshot) {
 
  Timestamp? timestamp = snapshot['time'];
  DateTime commentTime = timestamp != null ? timestamp.toDate() : DateTime.now();
  DateTime now = DateTime.now();

  Duration difference = now.difference(commentTime);
  String timeDifference = _formatTimeDifference(difference);

  return ListTile(
    leading: GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileScreen(Uid: snapshot['uid']), 
        ));
      },
      child: ClipOval(
        child: SizedBox(
          height: 35.h,
          width: 35.w,
          child: CachedImage(
            snapshot['profileImage'],
          ),
        ),
      ),
    ),
    title: GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileScreen(Uid: snapshot['uid']), 
        ));
      },
      child: Text(
        snapshot['username'],
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
    subtitle: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot['comment'],
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Text(
            timeDifference,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color.fromARGB(255, 57, 50, 50),
            ),
          ),
        ),
      ],
    ),
  );
}


  String _formatTimeDifference(Duration difference) {
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inSeconds}s';
    }
  }
}
