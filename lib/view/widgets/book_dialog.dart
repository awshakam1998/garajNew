import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:garaj/helper/customs.dart';
import 'package:garaj/model/garaj.dart';
import 'package:garaj/model/reservation.dart';
import 'package:garaj/view/screen/home_screen_client.dart';
import 'package:garaj/viewmodel/auth_controller.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class BookDialog extends StatefulWidget {
  Garaj garaj;

  BookDialog({Key? key, required this.garaj}) : super(key: key);

  @override
  _BookDialogState createState() => _BookDialogState();
}

class _BookDialogState extends State<BookDialog> {
  // set up the buttons

  String month = 'Month';
  String day = 'Day';
  String hour = 'Hour';

  bool timingError = false;

  setData() {
    var uuid = const Uuid();
    final resUid = uuid.v1();
    Reservation reservation = Reservation(
        id: resUid,
        managerId: widget.garaj.managerId,
        userId: uid,
        status: "Pending",
        parkId: widget.garaj.id,
        day: day,
        hour: hour,
        month: month);
    reservationRef.doc(resUid).set(reservation.toJson()).then((value) {
      Navigator.pop(context);
      Navigator.pop(context);
      Customs().showHint('New reservation', 'Your reservation has been completed successfully\n$day/$month at $hour:00');
    }).onError((error, stackTrace) {
      log('$error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Park Info"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "Remaining: ${widget.garaj.available}/${widget.garaj.capacity} Parks"
              "\nAre you sure to Book this park?"),
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: DropdownButton<int>(
                  hint: Text(month),
                  items: <int>[
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                    7,
                    8,
                    9,
                    10,
                    11,
                    12,
                  ].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (_) {
                    month = '$_';
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: DropdownButton<int>(
                  hint: Text(day),
                  items: <int>[
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                    7,
                    8,
                    9,
                    10,
                    11,
                    12,
                    13,
                    14,
                    15,
                    16,
                    17,
                    18,
                    19,
                    20,
                    21,
                    22,
                    23,
                    24,
                    25,
                    26,
                    27,
                    28,
                    29,
                    30,
                    31
                  ].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (_) {
                    day = '$_';
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: DropdownButton<int>(
                  hint: Text('$hour:00'),
                  items: <int>[
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                    7,
                    8,
                    9,
                    10,
                    11,
                    12,
                    13,
                    14,
                    15,
                    16,
                    17,
                    18,
                    19,
                    20,
                    21,
                    22,
                    23,
                    24,
                  ].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (_) {
                    setState(() {
                      hour = '$_';
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
          // Text(date!.toIso8601String())
        ],
      ),
      actions: [
        FlatButton(
          child: const Text("cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: const Text("Book"),
          onPressed: () {
            if (month != 'Month' && day != "Day" && hour != 'Hour') {
              Customs().loading();
              reservationRef
                  .where('userId', isEqualTo: uid)
                  .get()
                  .then((value) {
                value.docs.forEach((element) {
                  var data = json.decode(json.encode(element.data()));
                  if (data['day'] == day &&
                      data['month'] == month &&
                      data['hour'] == hour) {
                    timingError = true;
                  }else{
                    timingError=false;
                  }
                  // Navigator.pop(context);
                });
              }).then((value) {
                if (timingError) {
                  Navigator.pop(context);
                  Get.snackbar(
                      'Timing error', 'You have a reservation at this time');
                } else {
                  setData();
                }
              });
            }
          },
        ),
      ],
    );
  }
}
