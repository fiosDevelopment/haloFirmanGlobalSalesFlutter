import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core.dart';

class MeetingHistoriView extends GetView<MeetingController> {
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                AppBarWidget(
                  title: "Histori meeting",
                  back: true,
                ),
                _buildListMeeting(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GetX<MeetingController> _buildListMeeting() {
    return GetX<MeetingController>(
      init: Get.put<MeetingController>(MeetingController()),
      builder: (MeetingController meetingController) {
        return meetingController.meetingEnds == null
            ? ShimmerBasic(count: 3, height: 100)
            : meetingController.meetingEnds.length < 1
                ? Center(
                    child: Text('Tidak ada data'),
                  )
                : ListView.builder(
                    itemCount: meetingController.meetingEnds.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 16),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      DateTime tgl = DateTime.fromMillisecondsSinceEpoch(
                          meetingController.meetingEnds[index].jadwal);
                      var data = meetingController.meetingEnds;
                      return GestureDetector(
                        onTap: () => Get.toNamed(Routes.MEETING_DETAIL,
                            arguments: meetingController.meetingEnds[index]),
                        child: Container(
                          height: 130,
                          margin:
                              EdgeInsets.only(bottom: 10, left: 15, right: 15),
                          padding:
                              EdgeInsets.only(left: 20, top: 20, bottom: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300],
                                  blurRadius: 4,
                                  offset: Offset(4, 8),
                                ),
                              ]),
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat.E("id_ID")
                                              .format(tgl)
                                              .toString(),
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
                                          DateFormat.MMM("id_ID")
                                              .format(tgl)
                                              .toString(),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 190,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: PopupMenuButton(
                                          icon: Icon(Icons.more_vert),
                                          itemBuilder: (context) =>
                                              <PopupMenuEntry>[
                                            PopupMenuItem(
                                              child: const Text('menu item'),
                                            ),
                                            PopupMenuItem(
                                              child: const Text('menu item'),
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 9,
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 25),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AvatarRowList(
                                      meetingController: meetingController,
                                      index: index,
                                      jenis: "jadwal",
                                    ),
                                    ButtonRounded(
                                      onTap: () {},
                                      backgroundColor: data[index].status ==
                                              "Terjadwal"
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
      },
    );
  }
}
