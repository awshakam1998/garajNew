import 'package:flutter/material.dart';
import 'package:garaj/model/reservation.dart';
import 'package:garaj/view/screen/home_screen_client.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class ChangeReservationStatus extends StatefulWidget {
  final Reservation res;

  const ChangeReservationStatus({Key? key, required this.res})
      : super(key: key);

  @override
  _ChangeReservationStatusState createState() =>
      _ChangeReservationStatusState();
}

class _ChangeReservationStatusState extends State<ChangeReservationStatus> {
  bool pending = false;
  bool accepted = false;
  bool rejected = false;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      contentPadding: EdgeInsets.all(30),
      children: [
        const Text(
          'Change booking status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text(
                  'Pending',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                Checkbox(
                  value: pending,
                  onChanged: (v) {
                    setState(() {
                      pending = v!;
                      accepted = false;
                      rejected = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                const Text(
                  'Accepted',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Checkbox(
                  value: accepted,
                  onChanged: (v) {
                    setState(() {
                      accepted = v!;
                      pending = false;
                      rejected = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                const Text(
                  'Rejected',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                Checkbox(
                  value: rejected,
                  onChanged: (v) {
                    setState(() {
                      rejected = v!;
                      pending = false;
                      accepted = false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        MaterialButton(
          height: 45,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          minWidth: Get.width,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            reservationRef.doc(widget.res.id).update({
              'status': pending
                  ? 'Pending'
                  : accepted
                      ? 'Accepted'
                      : rejected
                          ? 'Rejected'
                          : 'Error'
            });
            // parkingRef.doc(widget.res.parkId).update({});

          },
          child: Text(
            'Save'.tr,
            style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
