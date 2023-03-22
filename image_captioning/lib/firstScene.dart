import 'package:flutter/material.dart';
import 'package:image_captioning/slideAnimation.dart';
import 'home.dart';

class firstScene extends StatelessWidget{
  const firstScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Stack(
          children: [
            Positioned(
              bottom: 20,
              right: 10,
              left: 10,
              child:button(
                  context: context,
                  text: 'Main Menu',
                  page:homeState()
              ),
            ),
          ],
        ),
      ),
    );
  }


  button({context,text,page}){
    return ElevatedButton(
      child: Text(text),
      onPressed: (){
        Navigator.of(context).pop(SlideAnimation(
            page: page,
            beginX: -1,
        ));
      },
      style: buttonStyle(),  //stylefrom
    );

  }


  buttonStyle(){
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.all(20.0),
      textStyle: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
      fixedSize: Size(300, 80),
      elevation: 15,
      shadowColor: Colors.deepOrange,
      primary: Colors.deepOrange,
      side: BorderSide(color: Colors.black, width:2.3),
      shape: StadiumBorder(),
    );  //stylefrom
  }




}