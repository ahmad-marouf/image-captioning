
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_captioning/slideAnimation.dart';

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

  card({
    required String text,
    IconData? icon ,
    required VoidCallback navigator
  }){
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      shadowColor: Colors.teal,
      elevation: 10,
      color: Colors.blueAccent,
      child: InkWell(
        onTap: navigator,
        child:  SizedBox(
          width: 300,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
               Icon(
                icon,
                size: 50,
              ),
              Text(text,
                  style: const TextStyle(
                      color: Colors.white
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }


