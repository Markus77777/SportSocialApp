import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app1/Firebase/firebase_service/firestor.dart';
import 'package:flutter_app1/Firebase/firebase_service/storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddPostTextScreen extends StatefulWidget {
  final File _file;
  AddPostTextScreen(this._file, {super.key});

  @override
  State<AddPostTextScreen> createState() => _AddPostTextScreenState();
}

class _AddPostTextScreenState extends State<AddPostTextScreen> {
  final caption = TextEditingController();
  final location = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text(
              '新增貼文',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageWithCaption(),
                  SizedBox(height: 16.h),
                  _buildLocationField(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      String postUrl = await StorageMethod()
                          .uploadImageToStorage('post', widget._file);
                      await Firebase_Firestor().CreatePost(
                        postImage: postUrl,
                        caption: caption.text,
                        location: location.text,
                      );
                      setState(() => isLoading = false);
                      if (mounted) Navigator.of(context).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                '分享',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildImageWithCaption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 180.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            image: DecorationImage(
              image: FileImage(widget._file),
              fit: BoxFit.cover,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              )
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: caption,
            maxLines: 6,
            minLines: 4,
            style: TextStyle(fontSize: 14.sp),
            decoration: const InputDecoration(
              hintText: '寫下貼文說明...',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: location,
        style: TextStyle(fontSize: 14.sp),
        decoration: const InputDecoration(
          hintText: '地點',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey),
        ),
      ),
    );
  }
}
