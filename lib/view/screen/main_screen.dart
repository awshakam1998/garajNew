import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garaj/view/screen/home_screen_client.dart';
import 'package:garaj/view/screen/home_screen_manager.dart';
import 'package:garaj/viewmodel/auth_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'loading_screen.dart';

LatLng currentLocation = LatLng(31.977059, 35.855561);

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Location location = new Location();
  bool serviceEnabled = false;
  PermissionStatus? permissionGranted;
  LocationData? locationData;

  requestPermission() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationData = await location.getLocation();
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
    location.onLocationChanged.listen((event) {
      currentLocation = LatLng(event.latitude!, event.longitude!);
      print(currentLocation);

    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('user').doc(uid).snapshots(),
        builder: (context, snap) {
          if (snap.hasData) {
            DocumentSnapshot? data = snap.data!;
            Map<dynamic, dynamic> map = json.decode(json.encode(data.data()));
            if (map['type'].toString() == 0.toString()) {
              return const HomeScreenManager();
            } else {
              return const HomeScreenClient();
            }
          }
          return const LoadingScreen();
        });
  }
}
