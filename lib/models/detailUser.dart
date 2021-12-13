// To parse this JSON data, do
//
//     final detailUser = detailUserFromJson(jsonString);

import 'dart:convert';

DetailUser detailUserFromJson(String str) =>
    DetailUser.fromJson(json.decode(str));

String detailUserToJson(DetailUser data) => json.encode(data.toJson());

class DetailUser {
  DetailUser({
    this.data,
  });

  Data data;

  factory DetailUser.fromJson(Map<String, dynamic> json) => DetailUser(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Data {
  Data({
    this.kdUser,
    this.nik,
    this.name,
    this.kdDiv,
    this.nmDivisi,
    this.hakAkses,
    this.keterangan,
    this.foto,
  });

  String kdUser;
  String nik;
  String name;
  String kdDiv;
  String nmDivisi;
  String hakAkses;
  String keterangan;
  String foto;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        kdUser: json["kdUser"],
        nik: json["nik"],
        name: json["name"],
        kdDiv: json["kd_div"],
        nmDivisi: json["nm_divisi"],
        hakAkses: json["hakAkses"],
        keterangan: json["keterangan"],
        foto: json["foto"],
      );

  Map<String, dynamic> toJson() => {
        "kdUser": kdUser,
        "nik": nik,
        "name": name,
        "kd_div": kdDiv,
        "nm_divisi": nmDivisi,
        "hakAkses": hakAkses,
        "keterangan": keterangan,
        "foto": foto,
      };
}
