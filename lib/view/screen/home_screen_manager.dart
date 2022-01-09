import 'dart:async';
import 'dart:convert';
import 'dart:developer'as dev;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:garaj/helper/customs.dart';
import 'package:garaj/model/garaj.dart';
import 'package:garaj/model/reservation.dart';
import 'package:garaj/view/screen/main_screen.dart';
import 'package:garaj/view/widgets/drawer_widget.dart';
import 'package:garaj/view/widgets/my_reservations.dart';
import 'package:garaj/viewmodel/auth_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class HomeScreenManager extends StatefulWidget {
  const HomeScreenManager({Key? key}) : super(key: key);

  @override
  State<HomeScreenManager> createState() => HomeScreenManagerState();
}

class HomeScreenManagerState extends State<HomeScreenManager> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? controller;
  Location location = new Location();
  bool serviceEnabled = false;
  PermissionStatus? permissionGranted;
  LocationData? locationData;
  final Set<Marker> _markers = <Marker>{};
  List<Garaj> garajs = [];
  CollectionReference parkingRef =
      FirebaseFirestore.instance.collection('parking');
  CollectionReference reservationRef =
      FirebaseFirestore.instance.collection('reservations');
  bool isLoad = false;

  @override
  void initState() {
    getParking();
  }

  void onMapCreated(GoogleMapController _cntlr) async {
    controller = _cntlr;
    location.getLocation().then((l) {
      currentLocation = LatLng(l.latitude!, l.longitude!);
      setState(() {});
      try {
        controller!.animateCamera(CameraUpdate.newLatLngBounds(
          getBounds(_markers.toList() +
              [
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: currentLocation,

                ),
              ]),
          100,
        ));
      } on Exception catch (e) {
        // TODO
      }
    });
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
          dev.log('${garaj.toJson()}');
          garajs.add(garaj);
          MarkerId markerId = MarkerId(
            garaj.id!,
          );
          LatLng latLng = LatLng(garaj.lat!, garaj.lng!);
          _markers.add(
            Marker(
                onTap: () {
                  showMarkerDetails(context, markerId, garaj);
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
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  showMarkerDetails(BuildContext context, MarkerId markerId, Garaj garaj) {
    // set up the buttons
    var uuid = const Uuid();
    final resUid = uuid.v1();
    Widget cancelButton = FlatButton(
      child: const Text("cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // Widget continueButton = FlatButton(
    //   child: const Text("Book"),
    //   onPressed: () {
    //     Customs().loading();
    //     Reservation reservation = Reservation(
    //         id: resUid,
    //         managerId: garaj.managerId,
    //         userId: uid,
    //         status: "Pending",
    //         parkId: garaj.id);
    //     reservationRef
    //         .doc(markerId.value)
    //         .set(reservation.toJson())
    //         .then((value) {
    //       Navigator.pop(context);
    //       Navigator.pop(context);
    //     }).onError((error, stackTrace) {
    //       log('$error');
    //     });
    //   },
    // );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Park Info"),
      content: Text("Remaining: ${garaj.available}/${garaj.capacity} Parks"),
      actions: [
        cancelButton,
        // continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  addMarker(Garaj garaj) {
    MarkerId markerId = MarkerId(garaj.id!);
    _markers.add(
      Marker(
          onTap: () {
            showMarkerDetails(context, markerId, garaj);
          },
          markerId: markerId,
          position: currentPosition.target),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: DrawerWidget(),
        key: _scaffoldkey,
        body: isLoad
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.satellite,
                initialCameraPosition: _kGooglePlex,
                markers: _markers,
                myLocationEnabled: true,
                layoutDirection: TextDirection.ltr,
                padding: const EdgeInsets.only(bottom: 60),
                onCameraMove: (position) {
                  setState(() {
                    currentPosition = position;
                  });
                },
                onMapCreated: onMapCreated,
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
                    _scaffoldkey.currentState!.openDrawer();
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
                      _scaffoldkey.currentState!
                          .showBottomSheet((context) => MyReservations(
                        isManager: true,
                      ));
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'My Reservation',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              StreamBuilder<QuerySnapshot>(
                                  stream: reservationRef
                                      .where('managerId', isEqualTo: uid)
                                      .get()
                                      .asStream(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot
                                          .data!.docs.isNotEmpty) {
                                        return Text(
                                          '${snapshot.data!.docs.length}',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    } else {
                                      return Container();
                                    }
                                  })
                            ],
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

  LatLngBounds getBounds(List<Marker> markers) {
    var lngs = markers.map<double>((m) => m.position.longitude).toList();
    var lats = markers.map<double>((m) => m.position.latitude).toList();

    double topMost = lngs.reduce(max);
    double leftMost = lats.reduce(min);
    double rightMost = lats.reduce(max);
    double bottomMost = lngs.reduce(min);

    LatLngBounds bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );

    return bounds;
  }
}
