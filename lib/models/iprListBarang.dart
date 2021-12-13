// To parse this JSON data, do
//
//     final iprListBarang = iprListBarangFromJson(jsonString);

import 'dart:convert';

IprListBarang iprListBarangFromJson(String str) =>
    IprListBarang.fromJson(json.decode(str));

String iprListBarangToJson(IprListBarang data) => json.encode(data.toJson());

class IprListBarang {
  IprListBarang({
    this.status,
    this.data,
  });

  String status;
  List<Datum> data;

  factory IprListBarang.fromJson(Map<String, dynamic> json) => IprListBarang(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.noIpr,
    this.kdBarang,
    this.kdBarcode,
    this.namaBarang,
    this.kelompok,
  });

  String noIpr;
  String kdBarang;
  String kdBarcode;
  String namaBarang;
  String kelompok;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        noIpr: json["noIpr"],
        kdBarang: json["kdBarang"],
        kdBarcode: json["kdBarcode"],
        namaBarang: json["namaBarang"],
        kelompok: json["kelompok"],
      );

  Map<String, dynamic> toJson() => {
        "noIpr": noIpr,
        "kdBarang": kdBarang,
        "kdBarcode": kdBarcode,
        "namaBarang": namaBarang,
        "kelompok": kelompok,
      };
}
