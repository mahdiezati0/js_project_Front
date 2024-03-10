import 'package:flutter/material.dart';

class SlideDots extends StatelessWidget {
  bool isActive;
  SlideDots(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: isActive ? 15 : 10,
        width: isActive ? 15 : 10,
        decoration: BoxDecoration(
          color: isActive ? Color(0xff00ADB5) : Color(0xff393E46),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ));
  }
}
