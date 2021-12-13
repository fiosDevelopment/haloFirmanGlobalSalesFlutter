import 'package:flutter/material.dart';

class ButtonIcon extends StatelessWidget {
  const ButtonIcon({
    @required this.onTap,
    @required this.text,
    @required this.buttonColor,
    @required this.icon,
    @required this.circleIcon,
    this.large,
    Key key,
  }) : super(key: key);

  final GestureTapCallback onTap;
  final String text;
  final Color buttonColor;
  final IconData icon;
  final bool circleIcon;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: large == true ? EdgeInsets.all(15) : EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: buttonColor),
        width: large == true
            ? MediaQuery.of(context).size.width / 2.4
            : MediaQuery.of(context).size.width / 3,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color:
                      circleIcon == true ? Colors.white30 : Colors.transparent),
              height: 30,
              width: 30,
              child: Icon(
                icon,
                size: 15,
                color: Colors.white70,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              width: large == true ? 80 : 70,
              child: Text(
                text,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
