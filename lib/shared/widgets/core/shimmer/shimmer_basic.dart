import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBasic extends StatelessWidget {
  const ShimmerBasic({Key key, @required this.count, @required this.height})
      : super(key: key);

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) {
        return Container(
          margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
          width: double.infinity,
          height: height,
          child: Shimmer.fromColors(
              baseColor: Colors.grey[350],
              highlightColor: Colors.grey[100],
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0)),
                width: double.infinity,
                height: 8.0,
              )),
        );
      },
    );
  }
}
