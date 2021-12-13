import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../core.dart';

class BuildReviewTab extends GetWidget<ProfileController> {
  const BuildReviewTab({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ProfileController>(
      init: Get.put<ProfileController>(ProfileController()),
      builder: (ProfileController profileSalesController) {
        return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 16),
            physics: NeverScrollableScrollPhysics(),
            itemCount: profileSalesController.reviews.length,
            itemBuilder: (context, index) {
              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('uID',
                          isEqualTo: profileSalesController.reviews[index].uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    DateTime tgl = DateTime(
                        profileSalesController.reviews[index].createdAt);
                    if (snapshot.data != null &&
                        snapshot.data.docs.length > 0) {
                      return Container(
                        margin:
                            EdgeInsets.only(bottom: 10, left: 15, right: 15),
                        padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[300],
                                blurRadius: 4,
                                offset: Offset(4, 8), // Shadow position
                              ),
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopSection(
                                snapshot, profileSalesController, index, tgl),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              profileSalesController.reviews[index].content,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            )
                          ],
                        ),
                      );
                    } else {
                      return ShimmerBasic(count: 1, height: 80);
                    }
                  });
            });
      },
    );
  }

  Row _buildTopSection(AsyncSnapshot<QuerySnapshot> snapshot,
      ProfileController profileSalesController, int index, DateTime tgl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(snapshot.data.docs[0]['imageUrl']),
              maxRadius: 17,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data.docs[0]['firstName'],
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SmoothStarRating(
                        allowHalfRating: false,
                        onRated: (v) {},
                        starCount: 5,
                        rating: profileSalesController.reviews[index].rating
                            .toDouble(),
                        size: 18.0,
                        isReadOnly: true,
                        color: Colors.orange,
                        borderColor: Colors.orange,
                        spacing: 0.0),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      profileSalesController.reviews[index].rating.toString() +
                          '.0',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            DateFormat.MMMMd("id_ID").format(tgl).toString(),
            style: TextStyle(
                fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
