import 'package:cloud_firestore/cloud_firestore.dart';

import '../core.dart';

class ReviewService {
  Stream<List<Review>> getReviewList() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return _firestore
        .collection("review")
        .orderBy("id", descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<Review> retVal = [];
      query.docs.forEach((element) {
        retVal.add(Review.fromDocumentSnapshot(element));
      });
      return retVal;
    });
  }
}
