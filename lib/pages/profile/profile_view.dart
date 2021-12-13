import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../core.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  var controller = Get.put(ProfileController());
  var loginController = Get.put(LoginController());
  // ignore: unused_field
  Animation _colorTween, _iconColorTween, _borderColorTween;
  // ignore: unused_field
  Animation<Offset> _transTween;
  // ignore: unused_field
  Animation<double> _sizeTween;
  bool isFollowing = false;
  bool followButtonClicked = false;
  bool isGridActive = true;
  List list = ['About me', 'Review', 'Sales history'];
  double get randHeight => Random().nextInt(100).toDouble();
  List<Widget> _randomChildren;

  followUser() {
    setState(() {
      isFollowing = true;
      followButtonClicked = true;
    });
  }

  unfollowUser() {
    setState(() {
      isFollowing = false;
      followButtonClicked = true;
    });
  }

  List<Widget> _randomHeightWidgets(BuildContext context) {
    _randomChildren ??= List.generate(1, (index) {
      return buildProfile();
    });

    return _randomChildren;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();

    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppBarWidget(
          title: "Profile",
        ),
        automaticallyImplyLeading: false,
        elevation: 0.0,
      ),
      body: DefaultTabController(
          length: 2,
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
                TabBar(
                  indicatorColor: kPrimaryColor,
                  indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 5.0),
                      insets: EdgeInsets.symmetric(horizontal: 60.0)),
                  tabs: [
                    Tab(
                      child: Text(
                        "Post",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Profile",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      postImagesWidget(),
                      DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              TabBar(
                                indicatorColor: kPrimaryColor,
                                indicator: UnderlineTabIndicator(
                                    borderSide: BorderSide(width: 5.0),
                                    insets:
                                        EdgeInsets.symmetric(horizontal: 60.0)),
                                tabs: [
                                  Tab(
                                    child: Text(
                                      "About me",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Tab(
                                    child: Text(
                                      "Review",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Tab(
                                    child: Text(
                                      "Sales history",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                  child: TabBarView(
                                children: [
                                  _aboutMeTab(),
                                  BuildReviewTab(),
                                  Container(),
                                ],
                              ))
                            ],
                          ))
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Container _aboutMeTab() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 10, bottom: 15, top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.white),
      padding: EdgeInsets.all(16),
      child: Text(''),
    );
  }

  Widget postImagesWidget() {
    return GetX<ProfileController>(
        init: Get.put<ProfileController>(ProfileController()),
        builder: (ProfileController postController) {
          return postController.posts != null
              ? GridView.builder(
                  itemCount: postController.posts.length,
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Image.network(
                        postController.posts[index].content,
                        width: 125.0,
                        height: 125.0,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {},
                    );
                  })
              : Center(
                  child: Text('Tidak ada post'),
                );
        });
  }

  Widget detailsWidget(String count, String label) {
    return Column(
      children: <Widget>[
        Text(count,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.black)),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(label,
              style: TextStyle(fontSize: 13.0, color: Colors.black)),
        )
      ],
    );
  }

  Widget buildProfile() {
    return GetX<ProfileController>(
      initState: (_) async {
        AuthControllerss().readPreference('uid').then((value) async {
          Get.find<ProfileController>().user =
              await ProfileService().getUser(value.toString());
        });
      },
      builder: (_) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                  child: Container(
                      width: 90.0,
                      height: 90.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80.0),
                        image: DecorationImage(
                            image: _.user.imageUrl != null
                                ? NetworkImage(_.user.imageUrl)
                                : Container(),
                            fit: BoxFit.cover),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          detailsWidget(
                              controller.posts != null
                                  ? controller.posts.length.toString()
                                  : '0',
                              'Posts'),
                          Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: detailsWidget(
                                controller.followers != null
                                    ? controller.followers.length.toString()
                                    : '0',
                                'Followers'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: detailsWidget("5 / 5", 'Rating'),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 12.0, left: 20.0, right: 20.0),
                        child: GestureDetector(
                          child: buildButton(
                            text: "Logout",
                            backgroundcolor: Colors.red,
                            textColor: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 10.0),
              child: Text(_.user.firstName + ' ' + _.user.lastName,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0)),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  "Hidup ini indah walau tak punya uang",
                  style: TextStyle(fontSize: 13),
                )),
          ],
        );
      },
    );
  }

  Widget buildButton(
      {String text,
      Color backgroundcolor,
      Color textColor,
      GestureTapCallback function}) {
    return GestureDetector(
      onTap: () {
        loginController.signOut();
      },
      child: Container(
        width: 210.0,
        height: 30.0,
        decoration: BoxDecoration(
            color: backgroundcolor, borderRadius: BorderRadius.circular(4.0)),
        child: Center(
          child: Text(text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
