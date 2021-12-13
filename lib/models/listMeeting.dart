import 'package:cloud_firestore/cloud_firestore.dart';

class ListMeeting {
  String topik;
  String status;
  String createdAt;
  int jadwal;
  String sales;
  String dibuatOleh;
  String meetingid;
  List partisipan;

  ListMeeting(this.topik, this.status, this.createdAt, this.jadwal, this.sales,
      this.dibuatOleh, this.meetingid, this.partisipan);
  ListMeeting.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    topik = documentSnapshot["topik"];
    status = documentSnapshot["status"];
    createdAt = documentSnapshot["createdAt"];
    jadwal = documentSnapshot["jadwal"];
    sales = documentSnapshot["sales"];
    dibuatOleh = documentSnapshot["dibuatOleh"];
    meetingid = documentSnapshot["meetingId"];
    partisipan = documentSnapshot["partisipan"];
  }
}
