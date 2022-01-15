// To parse this JSON data, do
//
//     final reservation = reservationFromJson(jsonString);

import 'dart:convert';

Reservation reservationFromJson(String str) =>
    Reservation.fromJson(json.decode(str));

String reservationToJson(Reservation data) => json.encode(data.toJson());

class Reservation {
  Reservation({
    this.id,
    this.parkId,
    this.userId,
    this.status,
    this.managerId,
    this.dateTime,
    this.time,
    this.timeTo,
    this.lat,
    this.lng,
    this.parkName,
    this.price,
  });

  String? id;
  String? parkName;
  String? parkId;
  String? userId;
  String? status;
  String? managerId;
  String? dateTime;
  String? time;
  String? timeTo;
  String? lat;
  String? lng;
  String? price;

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        id: json["id"],
        dateTime: json['dateTime'],
        time: json['time'],
        timeTo: json['timeTo'] ?? '',
        parkId: json["parkId"],
        userId: json["userId"],
        status: json["status"],
        managerId: json["managerId"],
        lat: json["lat"],
        lng: json["lng"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dateTime": dateTime,
        "time": time,
        "timeTo": timeTo,
        "parkId": parkId,
        "lat": lat,
        "lng": lng,
        "price": price,
        "userId": userId,
        "status": status,
        "managerId": managerId,
      };
}
