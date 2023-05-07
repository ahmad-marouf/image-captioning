import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  width:width,
  height: height,
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
                 color: Colors.black,
              ),
              Text(text,
                  style: const TextStyle(
                    fontFamily: "Goldman",
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }


class InnerShadow extends SingleChildRenderObjectWidget {
  const InnerShadow({
    Key? key,
    this.shadows = const <Shadow>[],
    Widget? child,
  }) : super(key: key, child: child);

  final List<Shadow> shadows;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = _RenderInnerShadow();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderInnerShadow renderObject) {
    renderObject.shadows = shadows;
  }
}

class _RenderInnerShadow extends RenderProxyBox {
  late List<Shadow> shadows;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final bounds = offset & size;

    context.canvas.saveLayer(bounds, Paint());
    context.paintChild(child!, offset);

    for (final shadow in shadows) {
      final shadowRect = bounds.inflate(shadow.blurSigma);
      final shadowPaint = Paint()
        ..blendMode = BlendMode.srcATop
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcOut)
        ..imageFilter = ImageFilter.blur(
            sigmaX: shadow.blurSigma, sigmaY: shadow.blurSigma);
      context.canvas
        ..saveLayer(shadowRect, shadowPaint)
        ..translate(shadow.offset.dx, shadow.offset.dy);
      context.paintChild(child!, offset);
      context.canvas.restore();
    }

    context.canvas.restore();
  }
}

class BorderPainter extends CustomPainter {
  BorderPainter(this.borderColor, this.borderRadius);

  @required Color borderColor;
  @required double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height; // for convenient shortage
    double sw = size.width; // for convenient shortage
    double cornerSide = borderRadius; // sh * 0.1; // desirable value for corners side

    Paint paint = Paint()
      ..color = borderColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path()
      ..moveTo(cornerSide, 0)
      ..quadraticBezierTo(0, 0, 0, cornerSide)
      ..moveTo(0, sh - cornerSide)
      ..quadraticBezierTo(0, sh, cornerSide, sh)
      ..moveTo(sw - cornerSide, sh)
      ..quadraticBezierTo(sw, sh, sw, sh - cornerSide)
      ..moveTo(sw, cornerSide)
      ..quadraticBezierTo(sw, 0, sw - cornerSide, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;

}