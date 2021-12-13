import 'package:flutter/material.dart';

class ButtonRoundedWidget extends StatelessWidget {
  const ButtonRoundedWidget({
    @required this.titleButton,
    @required this.colorButton,
    @required this.colorText,
    @required this.onTap,
  });

  final String titleButton;
  final Color colorButton;
  final Color colorText;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorButton,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              titleButton,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorText, fontSize: 12.0),
            ),
          ),
        ),
      ),
    );
  }
}
