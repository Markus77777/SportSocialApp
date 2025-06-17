import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app1/Firebase/firebase_service/firebase_auth.dart';
import 'package:flutter_app1/util/dialog.dart';
import 'package:flutter_app1/util/exeption.dart';
import 'package:flutter_app1/util/imagepicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback show;
  SignupScreen(this.show, {super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final email = TextEditingController();
  FocusNode email_F = FocusNode();
  final password = TextEditingController();
  FocusNode password_F = FocusNode();
  final passwordConfirme = TextEditingController();
  FocusNode passwordConfirme_F = FocusNode();
  final username = TextEditingController();
  FocusNode username_F = FocusNode();
  final bio = TextEditingController();
  FocusNode bio_F = FocusNode();
  File? _imageFile;

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    password.dispose();
    passwordConfirme.dispose();
    username.dispose();
    bio.dispose();
    email_F.dispose();
    password_F.dispose();
    passwordConfirme_F.dispose();
    username_F.dispose();
    bio_F.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Center(
              child: Image.asset('images/logo.jpg'),
            ),
            SizedBox(height: 70.h),
            InkWell(
              onTap: () async {
                File? _imageFileTemp = await ImagePickerr().uploadImage('gallery');
                setState(() {
                  _imageFile = _imageFileTemp;
                });
              },
              child: CircleAvatar(
                radius: 36.r,
                backgroundColor: Colors.grey,
                child: _imageFile == null
                    ? CircleAvatar(
                        radius: 34.r,
                        backgroundImage: AssetImage('images/person.png'),
                        backgroundColor: Colors.grey.shade200,
                      )
                    : CircleAvatar(
                        radius: 34.r,
                        backgroundImage: FileImage(_imageFile!), // 直接使用 FileImage
                        backgroundColor: Colors.grey.shade200,
                      ),
              ),
            ),
            SizedBox(height: 40.h),
            TextFieldWidget(email, email_F, 'Email', Icons.email),
            SizedBox(height: 15.h),
            TextFieldWidget(username, username_F, 'Username', Icons.person),
            SizedBox(height: 15.h),
            TextFieldWidget(bio, bio_F, 'Bio', Icons.abc),
            SizedBox(height: 15.h),
            TextFieldWidget(password, password_F, 'Password', Icons.lock),
            SizedBox(height: 15.h),
            TextFieldWidget(passwordConfirme, passwordConfirme_F, 'Confirm Password', Icons.lock),
            SizedBox(height: 15.h),
            SignupButton(),
            SizedBox(height: 15.h),
            HaveAccountWidget()
          ],
        ),
      ),
    );
  }

  Widget HaveAccountWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Don't you have an account?  ",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          GestureDetector(
            onTap: widget.show,
            child: Text(
              "Login ",
              style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget SignupButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: InkWell(
        onTap: () async {
          try {
            await Authentication().Signup(
              email: email.text,
              password: password.text,
              passwordConfirme: passwordConfirme.text,
              username: username.text,
              bio: bio.text,
              profile: _imageFile ?? File(''), // 使用File('')若未選擇圖片
            );
          } on exceptions catch (e) {
            dialogBuilder(context, e.message);
          } catch (e) {
            // 捕獲未處理的錯誤
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
            'Sign up',
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
