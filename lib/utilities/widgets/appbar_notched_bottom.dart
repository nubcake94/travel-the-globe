import 'package:flutter/material.dart';
import 'package:travel_the_globe/utilities/constants/colors.dart';

class NotchedBottomAppBar extends StatelessWidget {
  final double elevation;
  final double notchMargin;
  final Color color;
  final double height;

  NotchedBottomAppBar({this.color = Colors.white, this.notchMargin = 5.0, this.elevation = 1.0, this.height = 40.0});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: elevation,
      notchMargin: notchMargin,
      color: color,
      shape: AutomaticNotchedShape(
        RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
      ),
    );
  }
}
