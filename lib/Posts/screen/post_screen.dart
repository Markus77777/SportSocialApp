import 'package:flutter/material.dart'; 
import 'package:flutter_app1/Posts/widget/post_widget.dart';

class PostScreen extends StatelessWidget {
  final snapshot;
  PostScreen(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),  // 可以根據需要修改標題
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // 返回上一頁
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(child: PostWidget(snapshot)),  // 您的 PostWidget 會顯示貼文內容
    );
  }
}
