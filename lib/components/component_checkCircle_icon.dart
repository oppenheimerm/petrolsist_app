import 'package:flutter/material.dart';
import 'package:petrolsist_app/resources/colours.dart';


class CheckCircleIcon extends StatelessWidget {
  final double? size;
  const CheckCircleIcon({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.check_circle_outline_outlined,

      color: AppColours.whiteColour,
      size: size,
    );
  }
}
