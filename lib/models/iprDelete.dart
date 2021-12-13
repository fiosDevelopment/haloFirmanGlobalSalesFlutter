// To parse this JSON data, do
//
//     final iprInput = iprInputFromJson(jsonString);

import 'dart:convert';

IprDelete iprDeleteFromJson(String str) => IprDelete.fromJson(json.decode(str));

String iprDeleteToJson(IprDelete data) => json.encode(data.toJson());

class IprDelete {
  IprDelete({
    this.status,
    this.success,
  });

  String status;
  String success;

  factory IprDelete.fromJson(Map<String, dynamic> json) => IprDelete(
        status: json["status"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
      };
}
