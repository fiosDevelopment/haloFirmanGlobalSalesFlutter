import 'package:cloud_firestore/cloud_firestore.dart';

class InboxService {
  Stream<QuerySnapshot> getInboxList(String uid) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return _firestore
        .collection("users")
        .doc(uid)
        .collection('notifications')
        .where("isRead", isEqualTo: false)
        .snapshots();
  }
}
