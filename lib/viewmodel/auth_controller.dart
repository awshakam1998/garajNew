import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:garaj/helper/customs.dart';
import 'package:garaj/is_logged_in.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? uid;
int? userType;


class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userRef = FirebaseFirestore.instance.collection('user');
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool securePassword = true;



  //code for login.
  Future<void> login() async {
    Customs customs = Customs();
    try {
      customs.loading();
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      ))
          .user;
      if (user != null) {
        uid = user.uid;
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('uid', user.uid);
        Get.back();
        Get.offAll(const IsLoggedIn());
      } else {
        Get.back();
        customs.showError();
      }
    } catch (e) {
      Get.back();
      customs.showError();
    }
  }

  //code for signUp.
  Future<void> signUp() async {
    Customs customs = Customs();
    try {
      customs.loading();
      final User? user = (await _auth.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      ))
          .user;
      if (user != null) {
        userRef.doc(user.uid).set({'email': user.email, 'type': 1});
        uid = user.uid;
        Get.back();
        customs.showHint('signUp'.tr, 'successfullyRequest'.tr);
      } else {
        Get.back();
        customs.showError();
      }
    } catch (e) {
      Get.back();
      customs.showError();
    }
  }
}
