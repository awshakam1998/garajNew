import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garaj/model/reservation.dart';
import 'package:garaj/view/screen/home_screen_client.dart';
import 'package:garaj/view/widgets/change_status_reservation.dart';
import 'package:garaj/viewmodel/auth_controller.dart';
import 'package:get/get.dart';

class MyReservations extends StatefulWidget {
  bool isManager;

  MyReservations({Key? key, required this.isManager}) : super(key: key);

  @override
  _MyReservationsState createState() => _MyReservationsState();
}

class _MyReservationsState extends State<MyReservations> {
  bool loading = true;
  List<Reservation> myReservations = [];

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
                      child: ListView.builder(
                          itemCount: myReservations.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (widget.isManager) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ChangeReservationStatus(
                                          res: myReservations[index],
                                        );
                                      });
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
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
                                                            FontWeight.bold),
                                                  ),
                                                Text(
                                                    '${myReservations[index].day!}/${myReservations[index].month!} at ${myReservations[index].hour}:00'),
                                                Text(
                                                  myReservations[index].status!,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal),
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
                          }),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
