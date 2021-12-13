import 'package:cloud_firestore/cloud_firestore.dart';

import '../core.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserList> getUser(String uid) async {
    try {
      DocumentSnapshot _doc =
          await _firestore.collection("users").doc(uid).get();

      return UserList.fromDocumentSnapshot(documentSnapshot: _doc);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<List<HomeMenu>> getMenuListSales() {
    return _firestore
        .collection("menuSales")
        .where("status", isEqualTo: 'on')
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map((QuerySnapshot query) {
      List<HomeMenu> retVal = [];
      query.docs.forEach((element) {
        retVal.add(HomeMenu.fromDocumentSnapshot(element));
      });
      return retVal;
    });
  }

  Stream<QuerySnapshot> getNewChatBadge(String uid) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return _firestore
        .collection("users")
        .doc(uid)
        .collection('notifications')
        .where("isRead", isEqualTo: false)
        .where("type", isEqualTo: "chat")
        .snapshots();
  }

  Stream<QuerySnapshot> getNewMeetingBadge(String uid) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return _firestore
        .collection("meetings")
        .where("partisipan", arrayContains: uid)
        .where("status", isEqualTo: "Baru")
        .snapshots();
  }

  Stream<QuerySnapshot> getUlasan(uID) {
    return _firestore
        .collection('meetings')
        .where("sales", isEqualTo: uID)
        .snapshots();
  }

  Stream<QuerySnapshot> getRating(meetingId) {
    return _firestore
        .collection('meetings')
        .doc(meetingId)
        .collection("rating")
        .snapshots();
  }
}
