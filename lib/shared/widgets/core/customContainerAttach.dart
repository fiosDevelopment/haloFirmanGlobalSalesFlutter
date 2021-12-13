import 'package:flutter/material.dart';

class CustomAttachContainer extends StatelessWidget {
  final String caption;
  final GestureTapCallback onTap;
  const CustomAttachContainer({
    @required this.caption,
    @required this.onTap,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.green[50],
            ),
            height: 40,
            width: 40,
            child: Icon(
              Icons.image,
              size: 20,
              color: Colors.green.shade400,
            ),
          ),
        ),
        SizedBox(
          height: 3,
        ),
        Text(
          caption,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
