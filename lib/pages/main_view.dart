import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halo_firman_sales/core.dart';

class MainView extends GetView<MainController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [HomeView(), InboxView(), ProfileView()],
      ),
      floatingActionButton: FutureBuilder(
          future: AuthControllerss().readPreference("uid"),
          builder: (context, sn) {
            return sn.data == null
                ? Container()
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .where("uID", isEqualTo: sn.data)
                        .snapshots(),
                    builder: (context, snapshot) {
                      return snapshot.data == null
                          ? Container()
                          : Visibility(
                              visible: snapshot.data.docs[0]["accountType"] ==
                                      "sales"
                                  ? true
                                  : false,
                              child: FloatingActionButton(
                                  onPressed: () {
                                    Get.toNamed(Routes.POST);
                                  },
                                  child: Icon(Icons.add),
                                  backgroundColor: kPrimaryColor),
                            );
                    });
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: NavigationWidget(controller: controller),
    );
  }
}
