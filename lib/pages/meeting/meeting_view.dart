import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core.dart';

class MeetingView extends GetView<MeetingController> {
  List<Widget> _randomChildren;

  List<Widget> _randomHeightWidgets(BuildContext context) {
    _randomChildren ??= List.generate(1, (index) {
      return Container();
    });

    return _randomChildren;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: AppBarWidget(
          title: "Meeting",
          back: true,
        ),
      ),
      body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
              headerSliverBuilder: (context, _) {
                return [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      _randomHeightWidgets(context),
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TabBar(
                      indicatorColor: Colors.grey,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [kPrimaryColor, kPrimaryColor]),
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.redAccent),
                      tabs: [
                        Tab(
                          child: Text(
                            "Permintaan baru",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Terjadwal",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Berakhir",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildListMeetingBaru(),
                        _buildListMeetingTerjadwal(),
                        _buildListMeetingEnd()
                      ],
                    ),
                  ),
                ],
              ))),
    );
  }

  GetX<MeetingController> _buildListMeetingBaru() {
    return GetX<MeetingController>(
      init: Get.put<MeetingController>(MeetingController()),
      builder: (MeetingController meetingController) {
        return meetingController.meetingsBarus == null
            ? ShimmerBasic(count: 3, height: 100)
            : meetingController.meetingsBarus.length < 1
                ? Center(
                    child: Text('Tidak ada data'),
                  )
                : _buildMeetingContent(meetingController, "baru");
      },
    );
  }

  GetX<MeetingController> _buildListMeetingTerjadwal() {
    return GetX<MeetingController>(
      init: Get.put<MeetingController>(MeetingController()),
      builder: (MeetingController meetingController) {
        return meetingController.meetings == null
            ? ShimmerBasic(count: 3, height: 100)
            : meetingController.meetings.length < 1
                ? Center(
                    child: Text('Tidak ada data'),
                  )
                : _buildMeetingContent(meetingController, "terjadwal");
      },
    );
  }

  GetX<MeetingController> _buildListMeetingEnd() {
    return GetX<MeetingController>(
      init: Get.put<MeetingController>(MeetingController()),
      builder: (MeetingController meetingController) {
        return meetingController.meetingEnds == null
            ? ShimmerBasic(count: 3, height: 100)
            : meetingController.meetingEnds.length < 1
                ? Center(
                    child: Text('Tidak ada data'),
                  )
                : _buildMeetingContent(meetingController, "berakhir");
      },
    );
  }

  ListView _buildMeetingContent(
      MeetingController meetingController, String status) {
    return ListView.builder(
        itemCount: status == 'baru'
            ? meetingController.meetingsBarus.length
            : status == "terjadwal"
                ? meetingController.meetings.length
                : meetingController.meetingEnds.length,
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 16),
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          DateTime tgl = DateTime.fromMillisecondsSinceEpoch(status == "baru"
              ? meetingController.meetingsBarus[index].jadwal
              : status == "terjadwal"
                  ? meetingController.meetings[index].jadwal
                  : meetingController.meetingEnds[index].jadwal);
          var data = status == "baru"
              ? meetingController.meetingsBarus
              : status == "terjadwal"
                  ? meetingController.meetings
                  : meetingController.meetingEnds;
          return GestureDetector(
            onTap: () => Get.toNamed(Routes.MEETING_DETAIL,
                arguments: status == "baru"
                    ? meetingController.meetingsBarus[index]
                    : status == "terjadwal"
                        ? meetingController.meetings[index]
                        : meetingController.meetingEnds[index]),
            child: Container(
              height: 130,
              margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
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
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat.E("id_ID").format(tgl).toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12),
                            ),
                            Text(
                              DateFormat.d().format(tgl).toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Text(
                              DateFormat.MMM("id_ID").format(tgl).toString(),
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        VerticalDivider(),
                        SizedBox(
                          width: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 190,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data[index].topik,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Meeting dimulai jam " +
                                        DateFormat("HH:mm")
                                            .format(tgl.toUtc())
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        _popUpMenuBuild(status, meetingController, index)
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 9,
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AvatarRowList(
                          meetingController: meetingController,
                          index: index,
                          jenis: "$status",
                        ),
                        ButtonRounded(
                          onTap: () {},
                          backgroundColor: data[index].status == "Baru"
                              ? Colors.green.withOpacity(.3)
                              : data[index].status == "Terjadwal"
                                  ? Colors.orange.withOpacity(.3)
                                  : data[index].status == "Aktif"
                                      ? Colors.green.withOpacity(.4)
                                      : data[index].status == "Berakhir"
                                          ? Colors.blue.withOpacity(.4)
                                          : Colors.red.withOpacity(.4),
                          text: data[index].status,
                          color: Colors.black,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Align _popUpMenuBuild(
      String status, MeetingController meetingController, int index) {
    return Align(
        alignment: Alignment.topRight,
        child: status == "baru"
            ? PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Text('Terima permintaan'),
                    onTap: () {
                      MeetingService().terimaPermintaan(
                          meetingController.meetingsBarus[index].meetingid);
                    },
                  ),
                  PopupMenuItem(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('uID',
                                isEqualTo: meetingController
                                    .meetingsBarus[index].dibuatOleh)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return snapshot.data == null
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    _moveTochatRoom(
                                        meetingController
                                            .meetingsBarus[index].dibuatOleh,
                                        snapshot.data);
                                  },
                                  child: Text('Chat dengan ' +
                                      snapshot.data.docs[0]['firstName']),
                                );
                        }),
                  ),
                ],
              )
            : status == "terjadwal"
                ? PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('uID',
                                    isEqualTo: meetingController
                                        .meetings[index].dibuatOleh)
                                .snapshots(),
                            builder: (context, snapshot) {
                              return snapshot.data == null
                                  ? Container()
                                  : GestureDetector(
                                      onTap: () {
                                        _moveTochatRoom(
                                            meetingController
                                                .meetings[index].dibuatOleh,
                                            snapshot.data);
                                      },
                                      child: Text('Chat dengan ' +
                                          snapshot.data.docs[0]['firstName']),
                                    );
                            }),
                      )
                    ],
                  )
                : PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('uID',
                                    isEqualTo: meetingController
                                        .meetingEnds[index].dibuatOleh)
                                .snapshots(),
                            builder: (context, snapshot) {
                              return snapshot.data == null
                                  ? Container()
                                  : GestureDetector(
                                      onTap: () {
                                        _moveTochatRoom(
                                            meetingController
                                                .meetingEnds[index].dibuatOleh,
                                            snapshot.data);
                                      },
                                      child: Text('Chat dengan ' +
                                          snapshot.data.docs[0]['firstName']),
                                    );
                            }),
                      )
                    ],
                  ));
  }

  Future<void> _moveTochatRoom(String uID, QuerySnapshot snapshot) async {
    try {
      AuthControllerss().readPreference('uid').then((value) {
        String chatID = ChatService().makeChatId(value, uID);
        Get.toNamed(
          Routes.CHAT_ROOM,
          arguments: [chatID, snapshot.docs[0]],
        );
      });
    } catch (e) {
      print(e.message);
    }
  }
}
