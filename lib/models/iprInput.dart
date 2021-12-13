// To parse this JSON data, do
//
//     final iprInput = iprInputFromJson(jsonString);

import 'dart:convert';

IprInput iprInputFromJson(String str) => IprInput.fromJson(json.decode(str));

String iprInputToJson(IprInput data) => json.encode(data.toJson());

class IprInput {
  IprInput({
    this.status,
    this.success,
    this.kelompok,
  });

  int status;
  String success;
  String kelompok;

  factory IprInput.fromJson(Map<String, dynamic> json) => IprInput(
        status: json["status"],
        success: json["success"],
        kelompok: json["kelompok"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "kelompok": kelompok,
      };
}
