import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Firebase/firebase_service/firestor.dart';
import 'package:flutter_app1/Firebase/firebase_service/storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class ReelsEditeScreen extends StatefulWidget {
  final File videoFile;
  const ReelsEditeScreen(this.videoFile, {super.key});

  @override
  State<ReelsEditeScreen> createState() => _ReelsEditeScreenState();
}

class _ReelsEditeScreenState extends State<ReelsEditeScreen> {
  final caption = TextEditingController();
  late VideoPlayerController controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        controller.setLooping(true);
        controller.setVolume(1.0);
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    caption.dispose();
    super.dispose();
  }

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
              '新增短片',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  // 影片顯示區
                  Container(
                    width: double.infinity,
                    height: 300.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                      color: Colors.black,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: controller.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // 說明欄位
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: caption,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: '寫下影片說明...',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  // 按鈕列
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        label: '分享',
                        background: Colors.blue,
                        textColor: Colors.white,
                        onPressed: () async {
                          setState(() => isLoading = true);
                          String reelsUrl = await StorageMethod()
                              .uploadImageToStorage('Reels', widget.videoFile);
                          await Firebase_Firestor().CreatReels(
                            video: reelsUrl,
                            caption: caption.text,
                          );
                          if (mounted) Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
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

  Widget _buildButton({
    required String label,
    required Color background,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 140.w,
        height: 45.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          border: borderColor != null
              ? Border.all(color: borderColor)
              : null,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
