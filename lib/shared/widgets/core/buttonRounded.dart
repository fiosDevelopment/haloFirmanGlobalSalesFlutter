import 'package:flutter/material.dart';

class ButtonRounded extends StatelessWidget {
  const ButtonRounded({
    Key key,
    @required this.backgroundColor,
    @required this.text,
    @required this.color,
    @required this.onTap,
  }) : super(key: key);

  final Color backgroundColor;
  final String text;
  final Color color;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 25,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25), color: backgroundColor),
        child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: color),
            )),
      ),
    );
  }
}
