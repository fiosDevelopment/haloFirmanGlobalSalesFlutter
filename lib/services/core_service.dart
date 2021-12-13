import 'package:cloud_firestore/cloud_firestore.dart';

class CoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future saveNotifications(String content, String myID, String idSender,
      String idReferensi, String type, int time) async {
    await _firestore
        .collection('users')
        .doc(idSender)
        .collection('notifications')
        .doc(time.toString())
        .set({
      'ID': time.toString(),
      'content': content,
      'idSender': myID,
      'idReferensi': idReferensi,
      'timestamp': Timestamp.now(),
      'isRead': false,
      'type': type,
    });
  }
}
