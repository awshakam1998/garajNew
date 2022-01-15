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
  final formattedTime = DateFormat('h:mm:ss a');

  setData({required int available, required bool isNow}) {
    final timeFromCheck = formattedTime.parse(formattedTimeFrom);
    final timeToCheck = formattedTime.parse(formattedTimeTo);

    Duration fromDuration = Duration(
        hours: timeFromCheck.hour,
        minutes: timeFromCheck.minute,
        seconds: timeFromCheck.second);
    Duration toDuration = Duration(
        hours: timeToCheck.hour,
        minutes: timeToCheck.minute,
        seconds: timeToCheck.second);
    Duration durationLeft = toDuration - fromDuration;
    List<String> durationArray = durationLeft.toString().split(':');
    int price = int.parse(durationArray[1]) > 45
        ? int.parse(durationArray[0]) + 1
        : int.parse(durationArray[0]);
    print('FRFFRFR ${price}');

    if (available >= 1) {
      var uuid = const Uuid();
      final resUid = uuid.v1();
      Reservation reservation = Reservation(
          id: resUid,
          managerId: widget.garaj.managerId,
          time: formattedTimeFrom,
          timeTo: formattedTimeTo,
          userId: uid,
          price: "$price",
          lat: widget.garaj.lat.toString(),
          lng: widget.garaj.lng.toString(),
          status: "Accepted",
          parkId: widget.garaj.id,
          dateTime: formatDate.format(date!));

      print('available: $available');
      reservationRef.doc(resUid).set(reservation.toJson()).then((value) async {
        // if (isNow) {
        await parkingRef.doc(widget.garaj.id).update({
          'available': available - 1,
        });
        // }
        Navigator.pop(context);
        Navigator.pop(context);
        Customs().showHint('New reservation',
            'Your reservation has been completed successfully\n${formatDate.format(date!)}');
      }).onError((error, stackTrace) {
        log('$error');
      });
    } else {
      Get.back();
      Get.snackbar('Park is full', 'You cannot book this park!');
    }
  }

  final formatDate = DateFormat('yyyy-MM-dd');
  String formattedTimeFrom = DateFormat('h:mm:ss a').format(DateTime.now());
  String formattedTimeTo = DateFormat('h:mm:ss a').format(DateTime.now());
  bool isCash = true;

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
                    const Text(
                      "\nAre you sure to Book this park?",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: MaterialButton(
                          color: Theme.of(context).primaryColor,
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
                                                  color: Theme.of(context)
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
                                : formatDate.format(DateTime.parse(
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
                          child: Column(
                            children: [
                              const Text(
                                "From",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18),
                              ),
                              MaterialButton(
                                  color: Theme.of(context).primaryColor,
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
                                                      height: (Get.height / 2) -
                                                          100,
                                                      width: Get.width,
                                                      child:
                                                          CupertinoDatePicker(
                                                        mode:
                                                            CupertinoDatePickerMode
                                                                .time,
                                                        onDateTimeChanged: (v) {
                                                          formattedTimeFrom =
                                                              DateFormat(
                                                                      'h:mm:ss a')
                                                                  .format(v);
                                                        },
                                                      ),
                                                    ),
                                                    Center(
                                                      child: MaterialButton(
                                                          color:
                                                              Theme.of(context)
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
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                    formattedTimeFrom,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "To",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18),
                              ),
                              MaterialButton(
                                  color: Theme.of(context).primaryColor,
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
                                                      height: (Get.height / 2) -
                                                          100,
                                                      width: Get.width,
                                                      child:
                                                          CupertinoDatePicker(
                                                        mode:
                                                            CupertinoDatePickerMode
                                                                .time,
                                                        onDateTimeChanged: (v) {
                                                          formattedTimeTo =
                                                              DateFormat(
                                                                      'h:mm:ss a')
                                                                  .format(v);
                                                        },
                                                      ),
                                                    ),
                                                    Center(
                                                      child: MaterialButton(
                                                          color:
                                                              Theme.of(context)
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
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                    formattedTimeTo,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: MaterialButton(
                            onPressed: () {
                              setState(() {
                                isCash = true;
                              });
                            },
                            shape: RoundedRectangleBorder(
                                side:
                                    BorderSide(color: Get.theme.primaryColor)),
                            color:
                                isCash ? Get.theme.primaryColor : Colors.white,
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(14),
                                child: Text('Cash on delivery'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: MaterialButton(
                            onPressed: () {
                              setState(() {
                                isCash = false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                                side:
                                    BorderSide(color: Get.theme.primaryColor)),
                            color:
                                !isCash ? Get.theme.primaryColor : Colors.white,
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(14.0),
                                child: Text('Credit Card'),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                              color:
                                  int.parse(park['available'].toString()) >= 1
                                      ? Colors.green
                                      : Colors.grey,
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
                                      if (data['dateTime'].toString() ==
                                          formatDate.format(date!).toString()) {
                                        timingError = true;
                                      }
                                      // Navigator.pop(context);
                                    });
                                  }).then((value) {
                                    if (timingError) {
                                      Navigator.pop(context);
                                      Get.snackbar('Timing error',
                                          'You have a reservation at this time');
                                      timingError = false;
                                    } else {
                                      bool isNow = formatDate.format(date!) ==
                                          formatDate.format(DateTime.now());
                                      bool available = (int.parse(
                                              park['available'].toString()) >
                                          0);
                                      if (available && isNow) {
                                        print(
                                            '1:available $available : isNow $isNow');
                                        setData(
                                            available: int.parse(
                                                park['available'].toString()),
                                            isNow: formatDate.format(date!) ==
                                                formatDate
                                                    .format(DateTime.now()));
                                      } else if (!isNow) {
                                        print(
                                            '2:available $available : isNow $isNow');

                                        setData(
                                            available: int.parse(
                                                park['available'].toString()),
                                            isNow: isNow);
                                      } else {
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
