import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class Employee {
  int id;
  String name;
  String avatar;
  String mobile;
  String address;
  String email;
  String dob;
  LatLng latLong;

  Employee({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.address,
    this.dob,
    this.latLong,
    this.avatar,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => new Employee(
        id: json["empid"],
        name: json["ename"],
        mobile: json["mobile"],
        email: json["emailid"],
        address: json['address'],
        latLong: LatLng(json['latt'], json['long']),
        dob: json['date_of_birth'],
        avatar: json["profilepic"],
      );

  Map<String, dynamic> toJson() => {
        "empid": id,
        "ename": name,
        "mobile": mobile,
        "addr": address,
        "email": email,
        "dob": DateFormat('yyyy-MM-dd').format(DateTime.parse(dob)),
        "latt": latLong.latitude,
        "long": latLong.longitude,
        "profilepic": avatar,
      };


}
