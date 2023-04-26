
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget defaultButton({
  //required Function function,
  double width=double.infinity,
  Color backGroundColor= Colors.blue,
  bool isUpperCase=true,
  Icon? icon,
  required String text,
  required VoidCallback function,

})=>Container(
  width:width,
  child: MaterialButton(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    onPressed: function,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        icon != null ? icon : SizedBox(),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              isUpperCase? text.toUpperCase() : text,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: backGroundColor,
  ),
);

Widget defaultElevatedButton({
  required String text,
  bool isUpperCase=true,
  required VoidCallback function,
})=>ElevatedButton(
    onPressed: function,
    child: Text(
      isUpperCase ? text.toUpperCase() : text,
    ),
);
