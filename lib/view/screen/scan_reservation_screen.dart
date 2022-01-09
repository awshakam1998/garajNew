
import 'dart:async';


import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garaj/helper/customs.dart';
import 'package:garaj/model/reservation.dart';
import 'package:garaj/view/screen/home_screen_client.dart';
import 'package:get/get.dart';

class ScanScreen extends StatefulWidget {

  final Reservation reservation;

  const ScanScreen({Key? key, required this.reservation}) : super(key: key);

  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<ScanScreen> {
  String barcode = "";

  @override
  initState() {
    super.initState();
  }


  updateReservationStatus(){
    Customs().loading();
    reservationRef
        .doc(widget.reservation.id)
        .update({'status':widget.reservation.status=='Accepted'?'Check-In':'Expired'}).then((value) {
          setState(() {
            widget.reservation.status=widget.reservation.status=='Accepted'?'Check-In':'Expired';
          });
          Get.back();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: Column(
          children:[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Park name: ' + widget.reservation.parkName!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Reservation date: ' + widget.reservation.dateTime!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Reservation time: ' + widget.reservation.time!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Reservation status: ' + widget.reservation.status!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: MaterialButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: scan,
                    child:  Text(widget.reservation.status=="Accepted"?'Check In by QR Code':'Check out by QR Code')
                ),
              ),
            )
            ,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(barcode, textAlign: TextAlign.center,),
            )
            ,
          ],
        ));
  }

  Future scan() async {
    try {
      var result = await BarcodeScanner.scan();
      updateReservationStatus();

      print('r:${result.rawContent}');
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}