// To parse this JSON data, do
//
//     final reservation = reservationFromJson(jsonString);

import 'dart:convert';

Reservation reservationFromJson(String str) => Reservation.fromJson(json.decode(str));

String reservationToJson(Reservation data) => json.encode(data.toJson());

class Reservation {
  Reservation({
    this.id,
    this.parkId,
    this.userId,
    this.status,
    this.managerId,
    this.day,
    this.month,
    this.hour,
    this.parkName,
  });

  String? id;
  String? parkName;
  String? parkId;
  String? userId;
  String? status;
  String? managerId;
  String? month;
  String? day;
  String? hour;

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
    id: json["id"],
    day: json["day"],
    month: json["month"],
    hour: json["hour"],
    parkId: json["parkId"],
    userId: json["userId"],
    status: json["status"],
    managerId: json["managerId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "day": day,
    "month": month,
    "hour": hour,
    "parkId": parkId,
    "userId": userId,
    "status": status,
    "managerId": managerId,
  };
}
