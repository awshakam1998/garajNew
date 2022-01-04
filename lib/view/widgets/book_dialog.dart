import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garaj/helper/customs.dart';
import 'package:garaj/model/garaj.dart';
import 'package:garaj/model/reservation.dart';
import 'package:garaj/view/screen/home_screen_client.dart';
import 'package:garaj/viewmodel/auth_controller.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:intl/intl.dart';

class BookDialog extends StatefulWidget {
  Garaj garaj;

  BookDialog({Key? key, required this.garaj}) : super(key: key);

  @override
  _BookDialogState createState() => _BookDialogState();
}

class _BookDialogState extends State<BookDialog> {
  // set up the buttons

  bool timingError = false;

  DateTime? date = DateTime.now();

  setData({required int available, required bool isNow}) {
    var uuid = const Uuid();
    final resUid = uuid.v1();
    Reservation reservation = Reservation(
        id: resUid,
        managerId: widget.garaj.managerId,
        userId: uid,
        status: isNow ? "Accepted" : "Pending",
        parkId: widget.garaj.id,
        dateTime: f.format(date!));

    reservationRef.doc(resUid).set(reservation.toJson()).then((value) async {
      if (isNow) {
        await parkingRef.doc(widget.garaj.id).update({
          'available': available - 1,
        });
      }
      Navigator.pop(context);
      Navigator.pop(context);
      Customs().showHint('New reservation',
          'Your reservation has been completed successfully\n${f.format(date!)}');
    }).onError((error, stackTrace) {
      log('$error');
    });
  }

  final f = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // title: const
      appBar: AppBar(
        title: const Text('Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<DocumentSnapshot>(
            stream: parkingRef.doc(widget.garaj.id).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<dynamic, dynamic> park =
                json.decode(json.encode(snapshot.data!.data()));
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Park Info",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Park name: ' + park['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Remaining: ${park['available']}/${park['capacity']} Parks"
                          "\nAre you sure to Book this park?",
                      style: const TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: MaterialButton(
                          color: Theme
                              .of(context)
                              .primaryColor,
                          minWidth: Get.width,
                          height: 45,
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: Get.height / 2,
                                      width: Get.width,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: (Get.height / 2) - 100,
                                              width: Get.width,
                                              child: CupertinoDatePicker(
                                                mode: CupertinoDatePickerMode
                                                    .date,
                                                // initialDateTime: DateTime.now(),
                                                // maximumDate: DateTime(2022, 12, 31),
                                                // minimumDate: DateTime.now(),

                                                maximumYear: 2022,
                                                minimumYear: 2022,
                                                minimumDate: DateTime.now(),
                                                maximumDate:
                                                DateTime(2022, 12, 31),
                                                // minimumYear: DateTime.now().year,

                                                onDateTimeChanged: (v) {
                                                  date = v;
                                                },
                                              ),
                                            ),
                                            Center(
                                              child: MaterialButton(
                                                  color: Theme
                                                      .of(context)
                                                      .primaryColor,
                                                  minWidth: Get.width,
                                                  height: 45,
                                                  onPressed: () {
                                                    setState(() {});
                                                    Get.back();
                                                  },
                                                  child: const Text(
                                                    'Save',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Text(
                            date == null
                                ? 'Date Picker'
                                : f.format(DateTime.parse(
                                date!.toIso8601String().toString())),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: MaterialButton(
                              color: Colors.red,
                              height: 45,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: MaterialButton(
                              color: Colors.green,
                              height: 45,
                              onPressed: () {
                                if (date != null) {
                                  Customs().loading();
                                  reservationRef
                                      .where('userId', isEqualTo: uid)
                                      .get()
                                      .then((value) {
                                    value.docs.forEach((element) {
                                      var data = json
                                          .decode(json.encode(element.data()));
                                      if (data['dateTime'].toString() == f.format(date!).toString()) {
                                      timingError = true;
                                      }
                                      // Navigator.pop(context);
                                      });
                                  }).then((value) {
                                    if (timingError) {
                                      Navigator.pop(context);
                                      Get.snackbar('Timing error',
                                          'You have a reservation at this time');
                                      timingError=false;
                                    } else {
                                      bool isNow = f.format(date!) ==
                                          f.format(DateTime.now());
                                      bool available = (int.parse(
                                          park['available']
                                              .toString()) >
                                          0);
                                      if (available && isNow) {
                                        print(
                                            '1:available $available : isNow $isNow');
                                        setData(
                                            available: int.parse(
                                                park['available'].toString()),
                                            isNow: f.format(date!) ==
                                                f.format(DateTime.now()));
                                      } else if (!isNow) {
                                        print(
                                            '2:available $available : isNow $isNow');

                                        setData(
                                            available: int.parse(
                                                park['available'].toString()),
                                            isNow: isNow);
                                      }
                                      else {
                                        print(
                                            '3:available $available : isNow $isNow');

                                        Get.back();
                                        Get.snackbar(
                                            'Park is busy', 'The Park is full');
                                      }
                                    }
                                  });
                                }
                              },
                              child: const Text(
                                'Book',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              )),
                        ),
                      ],
                    )
                    // Text(date!.toIso8601String())
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
