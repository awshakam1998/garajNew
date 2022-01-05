import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:garaj/model/garaj.dart';
import 'package:garaj/model/reservation.dart';
import 'package:garaj/view/widgets/book_dialog.dart';
import 'package:garaj/view/widgets/drawer_widget.dart';
import 'package:garaj/view/widgets/my_reservations.dart';
import 'package:garaj/viewmodel/auth_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreenClient extends StatefulWidget {
  const HomeScreenClient({Key? key}) : super(key: key);

  @override
  State<HomeScreenClient> createState() => HomeScreenClientState();
}

CollectionReference parkingRef =
    FirebaseFirestore.instance.collection('parking');
CollectionReference userRef = FirebaseFirestore.instance.collection('user');
CollectionReference reservationRef =
    FirebaseFirestore.instance.collection('reservations');

class HomeScreenClientState extends State<HomeScreenClient> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  List<Garaj> garajs = [];

  bool isLoad = false;

  bool hasReservation = false;

  Reservation? reservation;

  @override
  void initState() {
    getParking();
    super.initState();
  }

  getParking() async {
    setState(() {
      isLoad = true;
    });
    parkingRef.get().then((value) {
      if (value.docs != null || value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          Garaj garaj =
              Garaj.fromJson(json.decode(json.encode(element.data())));
          log('${garaj.toJson()}');
          garajs.add(garaj);
          MarkerId markerId = MarkerId(
            garaj.id!,
          );
          LatLng latLng = LatLng(garaj.lat!, garaj.lng!);
          _markers.add(
            Marker(
                onTap: () {
                  Get.to(BookDialog(
                    garaj: garaj,
                  ));
                },
                markerId: markerId,
                position: latLng),
          );
          setState(() {
            isLoad = false;
          });
        });
      } else {
        setState(() {
          isLoad = false;
        });
      }
    }).then((value) {
      setState(() {
        isLoad = false;
      });
    });
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.950359, 35.886843),
    zoom: 19.4746,
  );
  CameraPosition currentPosition = const CameraPosition(
      target: LatLng(31.950359, 35.886843), zoom: 19.151926040649414);
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawerWidget(),
        key: _scaffoldKey,
        floatingActionButton: userType == 0
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: SizedBox(
                  height: 70,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'assets/booking.png',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                      )
                    ],
                  ),
                ),
              )
            : null,
        body: isLoad
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.satellite,
                      initialCameraPosition: _kGooglePlex,
                      markers: _markers,
                      zoomControlsEnabled: false,
                      layoutDirection: TextDirection.ltr,
                      padding: const EdgeInsets.only(bottom: 60),
                      onCameraMove: (position) {
                        setState(() {
                          currentPosition = position;
                        });
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: IgnorePointer(
                          ignoring: true,
                          child: Container(
                              height: 160,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/pin.svg',
                                    height: 100,
                                    color: Colors.red,
                                  ),
                                ],
                              ))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState!.openDrawer();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
                            )),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState!.showBottomSheet(
                                (context) =>  MyReservations(isManager: false,));
                          },
                          child: Container(
                            height: 40,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  width: 70,
                                  height: 2,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(300),
                                      color: Colors.black),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'My Reservation',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15))),
                          ),
                        ))
                  ],
                ),
              ));
  }

  addMarker(Garaj garaj) {
    MarkerId markerId = MarkerId(garaj.id!);
    _markers.add(
      Marker(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return BookDialog(
                  garaj: garaj,
                );
              },
            );
          },
          markerId: markerId,
          position: currentPosition.target),
    );
    setState(() {});
  }
}
