// To parse this JSON data, do
//
//     final iprUserList = iprUserListFromJson(jsonString);

import 'dart:convert';

List<IprUserList> iprUserListFromJson(String str) => List<IprUserList>.from(
    json.decode(str).map((x) => IprUserList.fromJson(x)));

String iprUserListToJson(List<IprUserList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IprUserList {
  IprUserList({
    this.status,
    this.data,
  });

  String status;
  List<DatumUser> data;

  factory IprUserList.fromJson(Map<String, dynamic> json) => IprUserList(
        status: json["status"],
        data: List<DatumUser>.from(
            json["data"].map((x) => DatumUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DatumUser {
  DatumUser({
    this.kdUser,
    this.kdDivisi,
    this.namaUser,
    this.namaDivisi,
    this.nik,
  });

  String kdUser;
  String kdDivisi;
  String namaUser;
  String namaDivisi;
  String nik;

  factory DatumUser.fromJson(Map<String, dynamic> json) => DatumUser(
        kdUser: json["kdUser"],
        kdDivisi: json["kdDivisi"],
        namaUser: json["namaUser"],
        namaDivisi: json["namaDivisi"],
        nik: json["nik"],
      );

  Map<String, dynamic> toJson() => {
        "kdUser": kdUser,
        "kdDivisi": kdDivisi,
        "namaUser": namaUser,
        "namaDivisi": namaDivisi,
        "nik": nik,
      };
}
