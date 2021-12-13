import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../core.dart';

class NavigationWidget extends StatelessWidget {
  const NavigationWidget({
    Key key,
    @required this.controller,
  }) : super(key: key);

  final MainController controller;

  @override
  Widget build(BuildContext context) {
    return ValueBuilder<int>(
      initialValue: 0,
      builder: (value, updateFn) => Container(
        color: Colors.grey[200],
        child: BubbleBottomBar(
          hasNotch: true,
          fabLocation: BubbleBottomBarFabLocation.end,
          opacity: 1,
          currentIndex: value,
          onTap: (tab) {
            controller.pageController.animateToPage(tab,
                duration: controller.animationDuration, curve: Curves.ease);
            updateFn(tab);
          },
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          elevation: 8,
          hasInk: true,
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
                backgroundColor: kPrimaryColor,
                icon: Icon(
                  LineIcons.home,
                  color: Colors.black54,
                ),
                activeIcon: Icon(
                  LineIcons.home,
                  color: Colors.white,
                ),
                title: Text(
                  'Home',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal),
                )),
            BubbleBottomBarItem(
                backgroundColor: kPrimaryColor,
                icon: Stack(
                  children: [
                    Icon(
                      LineIcons.envelope,
                      color: Colors.black54,
                    ),
                    FutureBuilder(
                        future: AuthControllerss().readPreference("uid"),
                        builder: (context, sn) {
                          return sn.data == null
                              ? Text("")
                              : StreamBuilder<QuerySnapshot>(
                                  stream: InboxService().getInboxList(sn.data),
                                  builder: (context, snapshot) {
                                    return snapshot.data == null
                                        ? Text("")
                                        : snapshot.data.docs.length < 1
                                            ? Text("")
                                            : Positioned(
                                                left: 15,
                                                top: 0.0,
                                                right: 0.0,
                                                child: new Icon(
                                                    Icons.brightness_1,
                                                    size: 15.0,
                                                    color: Colors.redAccent),
                                              );
                                  });
                        })
                  ],
                ),
                activeIcon: Icon(
                  LineIcons.envelopeOpen,
                  color: Colors.white,
                ),
                title: Text('Inbox',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal))),
            BubbleBottomBarItem(
                backgroundColor: kPrimaryColor,
                icon: Icon(
                  LineIcons.userAlt,
                  color: Colors.black54,
                ),
                activeIcon: Icon(
                  LineIcons.user,
                  color: Colors.white,
                ),
                title: Text('Profile',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal)))
          ],
        ),
      ),
    );
  }
}
