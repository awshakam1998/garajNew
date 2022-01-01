import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garaj/view/screen/home_screen_client.dart';
import 'package:garaj/view/screen/home_screen_manager.dart';
import 'package:garaj/viewmodel/auth_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasData) {
            DocumentSnapshot? data = snap.data!;
            Map<dynamic, dynamic> map =
            json.decode(json.encode(data.data()));
            if(map['type'].toString()==0.toString()) {
              return HomeScreenManager();
            }
            else{
              return HomeScreenClient();
            }
          }
          return const CircularProgressIndicator();
        });
  }
}
