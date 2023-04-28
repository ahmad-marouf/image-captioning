import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

Widget defaultButton({
  //required Function function,
  double width=double.infinity,
  double height=double.infinity,
  Color backGroundColor= Colors.blue,
  bool isUpperCase=true,
  Icon? icon,
  required String text,
  required VoidCallback function,

})=>Container(
  width:width,height: height,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: backGroundColor,
  ),
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
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
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
      shadowColor: Colors.white,
      elevation: 30,
      color: Colors.white,
      child: InkWell(
        onTap: navigator,
        child:  SizedBox(
          width: 320,
          height: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              //RiveAnimation.asset("assets/rive/devices.riv"),
               Icon(
                icon,
                size: 50,
              ),
              Text(text,
                  style: const TextStyle(fontFamily: "CarterOne",
                      fontSize: 30,
                      color: Colors.black
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }


