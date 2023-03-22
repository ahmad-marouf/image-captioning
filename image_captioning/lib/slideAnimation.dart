import 'package:flutter/material.dart';

class SlideAnimation extends PageRouteBuilder{
  final page;
  double begin_x  ;
  double begin_y  ;
  double end_x  ;
  double end_y  ;

  SlideAnimation({this.page,   required this.begin_x,required this.begin_y,
   required this.end_x,required this.end_y}) : super(
    pageBuilder: (context,animation,animationtwo) => page,
    transitionsBuilder: (context,animation,animationtwo,child) {
      var begin = Offset(begin_x , begin_y);
      var end = Offset(end_x,end_y);
      var curve = Curves.ease;
      var tween = Tween(begin:begin ,end:end ).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation,
        child: child,
      );
    }
  );

}

