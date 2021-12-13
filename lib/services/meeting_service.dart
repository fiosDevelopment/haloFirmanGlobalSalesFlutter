import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../core.dart';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ListMeeting>> getMeetingBaruList(String uid) {
    return _firestore
        .collection("meetings")
        .where("partisipan", arrayContains: uid)
        .where("status", isEqualTo: "Baru")
        .snapshots()
        .map((QuerySnapshot query) {
      List<ListMeeting> retVal = [];
      query.docs.forEach((element) {
        retVal.add(ListMeeting.fromDocumentSnapshot(element));
      });
      return retVal;
    });
  }

  Stream<List<ListMeeting>> getMeetingList(String uid) {
    return _firestore
        .collection("meetings")
        .where("partisipan", arrayContains: uid)
        .where("status", whereIn: ["Terjadwal", "Aktif"])
        .snapshots()
        .map((QuerySnapshot query) {
          List<ListMeeting> retVal = [];
          query.docs.forEach((element) {
            retVal.add(ListMeeting.fromDocumentSnapshot(element));
          });
          return retVal;
        });
  }

  Stream<List<ListMeeting>> getMeetingHistoriList(String uid) {
    return _firestore
        .collection("meetings")
        .where("partisipan", arrayContains: uid)
        .where("status", whereIn: ["Berakhir", "Batal"])
        .snapshots()
        .map((QuerySnapshot query) {
          List<ListMeeting> retVal = [];
          query.docs.forEach((element) {
            retVal.add(ListMeeting.fromDocumentSnapshot(element));
          });
          return retVal;
        });
  }

  Future ubahJadwalMeeting(jadwal, meetingId) async {
    DateTime tgl = DateTime.fromMillisecondsSinceEpoch(jadwal);
    String tanggal = DateFormat.yMMMMEEEEd("id_ID").format(tgl);
    String jam = DateFormat("HH:mm").format(tgl.toUtc());

    _firestore
        .collection('meetings')
        .where("meetingId", isEqualTo: meetingId)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                _firestore
                    .collection('users')
                    .where("uID", isEqualTo: doc['dibuatOleh'])
                    .get()
                    .then((QuerySnapshot querySnapshot) => {
                          querySnapshot.docs.forEach((value) {
                            ChatService().sendNotificationMessageToPeerUser(
                                'text',
                                'Diubah oleh sales ke $tanggal $jam',
                                'Jadwal meeting diubah',
                                "",
                                value['FCMToken']);
                          })
                        });
              })
            });
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore
        .collection('meetings')
        .doc(meetingId)
        .update({'jadwal': jadwal});
    saveTimelineMeeting(meetingId, timeStamp, "Jadwal meeting diubah",
        "$tanggal $jam", "basic");
  }

  Future saveTimelineMeeting(meetingId, timeStamp, desc, subdesc, type) async {
    await _firestore
        .collection('meetings')
        .doc(meetingId)
        .collection("timeline")
        .doc(timeStamp)
        .set({
      'description': desc,
      'createdAt': timeStamp,
      'subDescription': subdesc,
      'type': type
    });
  }

  Future terimaPermintaan(meetingId) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseFirestore.instance
        .collection('meetings')
        .doc(meetingId)
        .update({
      'status': "Terjadwal",
    });
    saveTimelineMeeting(meetingId, timeStamp, "Permintaan meeting diterima",
        "Diterima oleh sales", "basic");
    _firestore
        .collection('meetings')
        .where("meetingId", isEqualTo: meetingId)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                _firestore
                    .collection('users')
                    .where("uID", isEqualTo: doc['dibuatOleh'])
                    .get()
                    .then((QuerySnapshot querySnapshot) => {
                          querySnapshot.docs.forEach((value) {
                            ChatService().sendNotificationMessageToPeerUser(
                                'text',
                                'Permintaan meeting diterima oleh sales',
                                'Permintaan meeting diterima',
                                "",
                                value['FCMToken']);
                          })
                        });
              })
            });
    Fluttertoast.showToast(msg: "Permintaan meeting diterima");
  }

  Future batalMeeting(meetingId, alasan) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore
        .collection('meetings')
        .doc(meetingId)
        .update({'status': "Batal"});
    saveTimelineMeeting(
        meetingId, timeStamp, "Meeting dibatalkan", "$alasan", 'basic');

    _firestore
        .collection('meetings')
        .where("meetingId", isEqualTo: meetingId)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                _firestore
                    .collection('users')
                    .where("uID", isEqualTo: doc['dibuatOleh'])
                    .get()
                    .then((QuerySnapshot querySnapshot) => {
                          querySnapshot.docs.forEach((value) {
                            ChatService().sendNotificationMessageToPeerUser(
                                'text',
                                'Meeting telah dibatalkan',
                                'Meeting telah berakhir',
                                "",
                                value['FCMToken']);
                          })
                        });
              })
            });
  }

  Future updatePartisipan(meetingId, id) async {
    await _firestore.collection('meetings').doc(meetingId).set({
      "partisipan": FieldValue.arrayUnion([id])
    }, SetOptions(merge: true));
  }

  Future buatNotulenMeeting(notulen, meetingId) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    _firestore
        .collection('meetings')
        .where("meetingId", isEqualTo: meetingId)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                _firestore
                    .collection('users')
                    .where("uID", isEqualTo: doc['dibuatOleh'])
                    .get()
                    .then((QuerySnapshot querySnapshot) => {
                          querySnapshot.docs.forEach((value) {
                            ChatService().sendNotificationMessageToPeerUser(
                                'text',
                                'Notulen telah dibuat oleh sales',
                                'Meeting telah berakhir',
                                "",
                                value['FCMToken']);
                          })
                        });
              })
            });
    await _firestore
        .collection('meetings')
        .doc(meetingId)
        .collection('notulen')
        .doc(timeStamp.toString())
        .set({
      'dateCreated': timeStamp,
      'content': notulen,
    });
    await _firestore
        .collection('meetings')
        .doc(meetingId)
        .update({'status': "Berakhir"});
    saveTimelineMeeting(
        meetingId, timeStamp, "Meeting berakhir", "$notulen", 'notulen');
  }
}
