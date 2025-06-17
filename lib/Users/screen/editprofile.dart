import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Firebase/model/usermodel.dart';
import 'package:flutter_app1/util/dialog.dart';
import 'package:flutter_app1/util/exeption.dart';
import 'package:flutter_app1/util/imagepicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app1/Firebase/firebase_service/firestor.dart';
import 'package:flutter_app1/Users/screen/profile_screen.dart';
import 'package:flutter_app1/Firebase/firebase_service/storage.dart';

class EditScreen extends StatefulWidget {
  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final username = TextEditingController();
  FocusNode username_F = FocusNode();
  final bio = TextEditingController();
  FocusNode bio_F = FocusNode();
  File? _imageFile;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    username.dispose();
    bio.dispose();
    username_F.dispose();
    bio_F.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // 返回上一頁
          },
        ),
        backgroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 70.h),
            InkWell(
              onTap: () async {
                File? _imageFileTemp = await ImagePickerr().uploadImage('gallery');
                setState(() {
                  _imageFile = _imageFileTemp;
                });
              },
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.grey,
                child: _imageFile == null
                    ? CircleAvatar(
                        radius: 100.r,
                        backgroundImage: AssetImage('images/person.png'),
                        backgroundColor: Colors.grey.shade200,
                      )
                    : CircleAvatar(
                        radius: 100.r,
                        backgroundImage: FileImage(_imageFile!), 
                        backgroundColor: Colors.grey.shade200,
                      ),
              ),
            ),
            SizedBox(height: 40.h),
            TextFieldWidget(username, username_F, 'Username', Icons.person),
            SizedBox(height: 15.h),
            TextFieldWidget(bio, bio_F, 'Bio', Icons.abc),
            SizedBox(height: 15.h),
            EditButton(),
            SizedBox(height: 15.h),
          ],
        ),
      ),
    );
  }

 Widget EditButton() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    child: InkWell(
      onTap: () async {
        try {
          Usermodel user = await Firebase_Firestor().getUser(UID: _auth.currentUser!.uid);
          String currentUsername = user.username;
          String currentBio = user.bio;
          String currentProfile = user.profile;

          String updatedUsername = username.text.isNotEmpty ? username.text : currentUsername;
          String updatedBio = bio.text.isNotEmpty ? bio.text : currentBio;
          String profileUrl = _imageFile != null 
              ? await StorageMethod().uploadImageToStorage('Profile', _imageFile!) 
              : currentProfile;

          await Firebase_Firestor().updateProfile(
            username: updatedUsername,
            bio: updatedBio,
            profile: profileUrl,
          );

          Navigator.of(context).pop();  
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreen(Uid: _auth.currentUser!.uid), 
          ));

          dialogBuilder(context, 'Profile updated successfully!');
        } on exceptions catch (e) {
          dialogBuilder(context, e.message);
        } catch (e) {
          print("Error: ${e.toString()}");
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          'Update',
          style: TextStyle(
            fontSize: 23.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

  Padding TextFieldWidget(TextEditingController controller, FocusNode focusNode,
      String hintText, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: TextField(
          style: TextStyle(fontSize: 18.sp, color: Colors.black),
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(
              icon,
              color: focusNode.hasFocus ? Colors.black : Colors.grey[600],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(
                width: 2.w,
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(
                width: 2.w,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
