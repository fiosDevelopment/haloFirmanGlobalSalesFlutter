import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    this.title,
    this.actions,
    this.back,
    Key key,
  }) : super(key: key);

  final String title;
  final List<Widget> actions;
  final bool back;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              back == true
                  ? Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 45,
                            height: 45,
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 17,
                        ),
                      ],
                    )
                  : SizedBox(),
              title == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 17.0),
                      child: Text(
                        title,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 27,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
          actions == null
              ? Container()
              : Row(
                  children: actions,
                )
        ],
      ),
    );
  }
}
