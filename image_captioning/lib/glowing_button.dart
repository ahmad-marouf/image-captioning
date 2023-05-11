import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlowingButton extends StatefulWidget{
  final Color color1;
  final Color color2;
  String text;
  const GlowingButton({
    required this.text,
    Key ? key,
    this.color1 = Colors.red,
    this.color2 = Colors.yellow,
}):super(key:key);

  @override
  GlowingButtonState createState()=>GlowingButtonState();
}

class GlowingButtonState extends State<GlowingButton>{
  var glowing= false;
  var scale =1.0;
  bool isUpperCase = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  double width = double.infinity;
  double height = 100;
  @override
   GlowingButtonState(Set set, {
    required String text,
});
  Widget build(BuildContext context) {

    return GestureDetector(
      onTapUp:(val){
        setState(() {
          glowing = false;
          scale = 1.0;
        });
      } ,
      onTapDown: (val){
        setState(() {
          glowing = true;
          scale = 1.1;
        });
      },
      child: AnimatedContainer(
        transform: Matrix4.identity()..scale(scale),
          duration: Duration(milliseconds: 200),
          width: width,
          height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
              colors: [
                widget.color1,
                widget.color2,
              ],
          ),
          boxShadow: glowing? [
            BoxShadow(
              blurRadius: 16,
              spreadRadius: 1,
              color: widget.color1.withOpacity(0.6),
              offset: Offset(-8,0),
            ),
            BoxShadow(
              blurRadius: 16,
              spreadRadius: 1,
              color: widget.color2.withOpacity(0.6),
              offset: Offset(8,0),
            ),
            BoxShadow(
              blurRadius: 32,
              spreadRadius: 16,
              color: widget.color1.withOpacity(0.2),
              offset: Offset(-8,0),
            ),
            BoxShadow(
              color: widget.color2,
              offset: Offset(8,0),
              spreadRadius: 16,
              blurRadius: 32,
            ),
          ]:[]
        ),
        child: Text(
          isUpperCase ? text.toUpperCase : text, 
        ),
      ),
    );
  }
}