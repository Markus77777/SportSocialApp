import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Posts/screen/add_screen.dart';
import 'package:flutter_app1/Explore/explor_screen.dart';
import 'package:flutter_app1/Explore/explore.dart';
import 'package:flutter_app1/screen/home.dart';
import 'package:flutter_app1/Users/screen/profile_screen.dart';
import 'package:flutter_app1/Reels/screen/reelsScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app1/Tasks/screen/todolist.dart';
import 'package:flutter_app1/Fitbit/FitbitPage.dart';

class Navigations_Screen extends StatefulWidget {
  const Navigations_Screen({super.key});

  @override
  State<Navigations_Screen> createState() => _Navigations_ScreenState();
}

int _currentIndex = 0;

class _Navigations_ScreenState extends State<Navigations_Screen> {
  late PageController pageController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: navigationTapped,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.watch),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.assignment,
                size: 28.0,
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          HomeScreen(),
          ReelScreen(),
          ExploreScreen(),
          FitbitPage(),
          Todolist(),
          ProfileScreen(
            Uid: _auth.currentUser!.uid,
          ),
        ],
      ),
    );
  }
}
