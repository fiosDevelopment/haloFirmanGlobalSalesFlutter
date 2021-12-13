// To parse this JSON data, do
//
//     final iprListPart = iprListPartFromJson(jsonString);

import 'dart:convert';

IprListPart iprListPartFromJson(String str) =>
    IprListPart.fromJson(json.decode(str));

String iprListPartToJson(IprListPart data) => json.encode(data.toJson());

class IprListPart {
  IprListPart({
    this.status,
    this.data,
  });

  String status;
  List<DatumPart> data;

  factory IprListPart.fromJson(Map<String, dynamic> json) => IprListPart(
        status: json["status"],
        data: List<DatumPart>.from(
            json["data"].map((x) => DatumPart.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DatumPart {
  DatumPart({
    this.noIpr,
    this.kdPart,
    this.masalah,
    this.namaBarang,
    this.kelompok,
    this.attach1,
    this.attach2,
    this.attach3,
  });

  String noIpr;
  String kdPart;
  String masalah;
  String namaBarang;
  String kelompok;
  String attach1;
  String attach2;
  String attach3;

  factory DatumPart.fromJson(Map<String, dynamic> json) => DatumPart(
        noIpr: json["noIpr"],
        kdPart: json["kdPart"],
        masalah: json["masalah"],
        namaBarang: json["namaBarang"],
        kelompok: json["kelompok"],
        attach1: json["attach1"],
        attach2: json["attach2"],
        attach3: json["attach3"],
      );

  Map<String, dynamic> toJson() => {
        "noIpr": noIpr,
        "kdPart": kdPart,
        "masalah": masalah,
        "namaBarang": namaBarang,
        "kelompok": kelompok,
        "attach1": attach1,
        "attach2": attach2,
        "attach3": attach3,
      };
}
