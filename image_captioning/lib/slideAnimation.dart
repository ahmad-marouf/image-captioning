import 'package:flutter/material.dart';

class SlideAnimation extends PageRouteBuilder{
  final page;
  double beginX;
  double beginY;
  double endX;
  double endY;

  SlideAnimation({this.page, this.beginX = 0, this.beginY = 0,
    this.endX = 0, this.endY = 0}) : super(
    pageBuilder: (context,animation,animationtwo) => page,
    transitionsBuilder: (context,animation,animationtwo,child) {
      Offset begin = Offset(beginX,beginY);
      Offset end = Offset(endX,endY);
      Curve curve = Curves.ease;
      var tween = Tween(begin:begin ,end:end ).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation,
        child: child,
      );
    }
  );
}

