
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_captioning/pages/preview_page.dart';
import 'package:image_captioning/components/shared_components.dart';
import 'package:image_captioning/components/slideAnimation.dart';
import 'package:image_picker/image_picker.dart';


class GalleryScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen>{
  File? image;

  Future pickImage()async{
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image== null) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      Uint8List pngBytes = await image.readAsBytes();
      if (mounted) {
        Navigator.of(context).pushReplacement(SlideAnimation(
            beginX: 1, page: CaptionGenerator(imageBytes: pngBytes, autoCapture: false)
        ));
      }

    } on PlatformException catch (e) {
      print("Failed to pick an image: $e");
    }
    }


  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 1),(){
      pickImage();
    }) ;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body:  Center(
          child: loader()
      ),
    );
  }
}
