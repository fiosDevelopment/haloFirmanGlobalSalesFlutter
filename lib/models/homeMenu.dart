import 'package:cloud_firestore/cloud_firestore.dart';

class HomeMenu {
  String icon;
  String title;
  String subTitle;
  String color;
  String status;

  HomeMenu(this.icon, this.title, this.subTitle, this.color, this.status);
  HomeMenu.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    icon = documentSnapshot["icon"];
    title = documentSnapshot["title"];
    subTitle = documentSnapshot["subtitle"];
    color = documentSnapshot["color"];
    status = documentSnapshot["status"];
  }
}
