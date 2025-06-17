import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Posts/screen/addpost_text.dart';
import 'package:flutter_app1/util/imagepicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final List<Widget> _mediaList = [];
  final List<File> _imagePaths = [];
  File? _selectedImage;
  int _selectedIndex = -1;

  Future<void> pickImageFromGallery() async {
    File? image = await ImagePickerr().uploadImage('gallery');
    if (image != null) {
      setState(() {
        _imagePaths.add(image);
        _mediaList.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          '新增貼文',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: TextButton(
              onPressed: _selectedImage != null
                  ? () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddPostTextScreen(_selectedImage!),
                      ));
                    }
                  : null,
              child: Text(
                '下一步',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: _selectedImage != null ? Colors.blue : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Center(
              child: ElevatedButton.icon(
                onPressed: pickImageFromGallery,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  '選擇圖片',
                  style: TextStyle(fontSize: 16.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: _mediaList.isEmpty
                  ? Center(
                      child: Text(
                        '尚未選擇任何圖片',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      itemCount: _mediaList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                              _selectedImage = _imagePaths[index];
                            });
                          },
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.transparent,
                                    width: 3.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: _mediaList[index],
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 22.sp,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
