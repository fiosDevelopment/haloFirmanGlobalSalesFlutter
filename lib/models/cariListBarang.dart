// To parse this JSON data, do
//
//     final cariListBarang = cariListBarangFromJson(jsonString);

import 'dart:convert';

List<CariListBarang> cariListBarangFromJson(String str) =>
    List<CariListBarang>.from(
        json.decode(str).map((x) => CariListBarang.fromJson(x)));

String cariListBarangToJson(List<CariListBarang> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CariListBarang {
  CariListBarang({
    this.kategori,
  });

  String kategori;

  factory CariListBarang.fromJson(Map<String, dynamic> json) => CariListBarang(
        kategori: json["kategori"],
      );

  Map<String, dynamic> toJson() => {
        "kategori": kategori,
      };
}
