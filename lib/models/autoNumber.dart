// To parse this JSON data, do
//
//     final autoNumber = autoNumberFromJson(jsonString);

import 'dart:convert';

AutoNumber autoNumberFromJson(String str) =>
    AutoNumber.fromJson(json.decode(str));

String autoNumberToJson(AutoNumber data) => json.encode(data.toJson());

class AutoNumber {
  AutoNumber({
    this.noIpr,
  });

  String noIpr;

  factory AutoNumber.fromJson(Map<String, dynamic> json) => AutoNumber(
        noIpr: json["no_ipr"],
      );

  Map<String, dynamic> toJson() => {
        "no_ipr": noIpr,
      };
}
