import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garaj/model/reservation.dart';
import 'package:garaj/view/screen/home_screen_client.dart';
import 'package:garaj/view/screen/reservation_details_screen.dart';
import 'package:garaj/view/screen/scan_reservation_screen.dart';
import 'package:garaj/view/widgets/change_status_reservation.dart';
import 'package:garaj/viewmodel/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyReservations extends StatefulWidget {
  bool isManager;

  MyReservations({Key? key, required this.isManager}) : super(key: key);

  @override
  _MyReservationsState createState() => _MyReservationsState();
}

class _MyReservationsState extends State<MyReservations> {
  bool loading = true;
  List<Reservation> myReservations = [];
  final today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final formatDate = DateFormat('yyyy-MM-dd');
  final formattedTime = DateFormat('h:mm:ss a');

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  getData() async {
    await reservationRef
        .where(widget.isManager ? 'managerId' : 'userId', isEqualTo: uid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        myReservations.add(
            Reservation.fromJson(json.decode(json.encode(element.data()))));
      });
    }).then((value) async {
      for (int i = 0; i < myReservations.length; i++) {
        await parkingRef.doc(myReservations[i].parkId).get().then((value) {
          var data = json.decode(json.encode(value.data()));
          print(data['name']);
          myReservations[i].parkName = data['name'];
          final dateToCheck = formatDate.parse(myReservations[i].dateTime!);
          final timeToCheck = formattedTime.parse(myReservations[i].time!);
          final aDate =
              DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
          if (aDate == dateToCheck) {
            Duration reservationDuration = Duration(
                hours: timeToCheck.hour,
                minutes: timeToCheck.minute,
                seconds: timeToCheck.second);
            Duration nowDuration = Duration(
                hours: DateTime.now().hour,
                minutes: DateTime.now().minute,
                seconds: DateTime.now().second);
            Duration durationLeft = nowDuration - reservationDuration;
            if (durationLeft > const Duration(minutes: 15) &&
                myReservations[i].status != 'Expired') {
              reservationRef
                  .doc(myReservations[i].id)
                  .update({'status': 'Expired'});
              parkingRef.doc(myReservations[i].parkId).update({
                'available': int.parse(data['available'].toString()) + 1,
              });
              myReservations[i].status = 'Expired';
              setState(() {});
            }
          }
        });
      }
    }).then((value) {});
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? SizedBox(
              width: Get.width,
              height: Get.height / 3,
              child: const Center(child: CircularProgressIndicator()))
          : SizedBox(
              height: Get.height / 2,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.clear,
                            color: Colors.white,
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myReservations.isEmpty
                          ? const Center(
                              child: Text('you don\'t have any reservations '),
                            )
                          : ListView.builder(
                              itemCount: myReservations.length,
                              itemBuilder: (context, index) {
                                if(widget.isManager) {
                                  return  myReservations[index].status!='Expired' ?GestureDetector(
                                    onTap: () {
                                      if (widget.isManager) {
                                        Get.to(ScanScreen(
                                          reservation: myReservations[index],));
                                      } else {
                                        final dateToCheck = formatDate.parse(
                                            myReservations[index].dateTime!);
                                        final aDate = DateTime(dateToCheck.year,
                                            dateToCheck.month, dateToCheck.day);
                                        if (myReservations[index].status !=
                                            'Expired') {
                                          if (aDate == dateToCheck) {
                                            Get.to(GenerateScreen(
                                                reservationId:
                                                myReservations[index].id!,
                                                reservation:
                                                myReservations[index]));
                                          } else {
                                            Get.snackbar('Reservation Date',
                                                'The booking date has not come yet');
                                          }
                                        } else {
                                          Get.snackbar('Reservation Expired',
                                              'You cannot navigate to park');
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: Container(
                                        color: Colors.grey.shade200,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.local_parking,
                                                    color: Theme
                                                        .of(context)
                                                        .primaryColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      if (myReservations[index]
                                                          .parkName !=
                                                          null)
                                                        Text(
                                                          myReservations[index]
                                                              .parkName!,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                      Text(myReservations[index]
                                                          .dateTime! +
                                                          ' -' +
                                                          myReservations[index]
                                                              .time!),
                                                      Text(
                                                        myReservations[index]
                                                            .status!,
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight
                                                                .normal),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Icon(
                                                Icons.location_on,
                                                size: 15,
                                                color: Colors.red,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ):const Center(
                                    child: Text('you don\'t have any active reservations '),
                                  );
                                }
                                else{
                                  return  GestureDetector(
                                    onTap: () {
                                      if (widget.isManager) {
                                        Get.to(ScanScreen(reservation: myReservations[index],));
                                      } else {
                                        final dateToCheck = formatDate.parse(
                                            myReservations[index].dateTime!);
                                        final aDate = DateTime(dateToCheck.year,
                                            dateToCheck.month, dateToCheck.day);
                                        if (myReservations[index].status !=
                                            'Expired') {
                                          if (aDate == dateToCheck) {
                                            Get.to(GenerateScreen(
                                                reservationId:
                                                myReservations[index].id!,
                                                reservation:
                                                myReservations[index]));
                                          }else{
                                            Get.snackbar('Reservation Date',
                                                'The booking date has not come yet');
                                          }
                                        } else {
                                          Get.snackbar('Reservation Expired',
                                              'You cannot navigate to park');
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: Container(
                                        color: Colors.grey.shade200,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.local_parking,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      if (myReservations[index]
                                                          .parkName !=
                                                          null)
                                                        Text(
                                                          myReservations[index]
                                                              .parkName!,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                      Text(myReservations[index]
                                                          .dateTime! +
                                                          ' -' +
                                                          myReservations[index]
                                                              .time!),
                                                      Text(
                                                        myReservations[index]
                                                            .status!,
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight
                                                                .normal),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Icon(
                                                Icons.location_on,
                                                size: 15,
                                                color: Colors.red,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
