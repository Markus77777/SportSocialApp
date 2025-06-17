import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Reels/screen/reels_edite_Screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app1/util/videopicker.dart';

class AddReelsScreen extends StatefulWidget {
  const AddReelsScreen({super.key});

  @override
  State<AddReelsScreen> createState() => _AddReelsScreenState();
}

class _AddReelsScreenState extends State<AddReelsScreen> {
  final List<Widget> _mediaList = [];
  final List<File> _videoPaths = [];
  File? _selectedVideo;
  int _selectedIndex = -1;

  Future<void> pickVideoFromGallery() async {
    File? video = await VideoPickerService().uploadVideo('gallery');
    if (video != null) {
      setState(() {
        _videoPaths.add(video);
        _mediaList.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(video),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          '新增短片',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Center(
              child: TextButton(
                onPressed: _selectedVideo != null
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ReelsEditeScreen(_selectedVideo!),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  '下一步',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: _selectedVideo != null ? Colors.blue : Colors.grey,
                  ),
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
                onPressed: pickVideoFromGallery,
                icon: const Icon(Icons.video_library_outlined),
                label: Text('從圖庫選擇短片', style: TextStyle(fontSize: 15.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
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
                        '尚未選擇短片',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(10.w),
                      itemCount: _mediaList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                      ),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                              _selectedVideo = _videoPaths[index];
                            });
                          },
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color:
                                        isSelected ? Colors.blue : Colors.transparent,
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
