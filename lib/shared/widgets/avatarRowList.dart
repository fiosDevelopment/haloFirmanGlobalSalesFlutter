import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core.dart';

class AvatarRowList extends StatelessWidget {
  const AvatarRowList({
    Key key,
    @required this.jenis,
    @required this.meetingController,
    @required this.index,
  }) : super(key: key);

  final String jenis;
  final MeetingController meetingController;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Row(
              children: List.generate(
                  jenis == "baru"
                      ? meetingController.meetingsBarus[index].partisipan.length
                      : jenis == "terjadwal"
                          ? meetingController.meetings[index].partisipan.length
                          : meetingController
                              .meetingEnds[index].partisipan.length, (i) {
            return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('uID',
                        isEqualTo: jenis == "baru"
                            ? meetingController
                                .meetingsBarus[index].partisipan[i]
                            : jenis == "terjadwal"
                                ? meetingController
                                    .meetings[index].partisipan[i]
                                : meetingController
                                    .meetingEnds[index].partisipan[i])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data != null && snapshot.data.docs.length > 0) {
                    return Tooltip(
                      waitDuration: Duration.zero,
                      showDuration: Duration.zero,
                      verticalOffset: -50,
                      message: "Fisda",
                      child: Container(
                        width: 25,
                        height: 25,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2)),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            snapshot.data.docs[0]['imageUrl']),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                });
          }))
        ],
      ),
    );
  }
}
