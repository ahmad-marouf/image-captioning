
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_captioning/pages/preview_page.dart';
import 'package:image_captioning/components/shared_components.dart';
import 'package:image_captioning/components/slideAnimation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';


class GalleryScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen>{
  Image ? image;
  Image ? pickedImage;

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
            beginX: 1, page: CaptionGenerator(imageBytes: pngBytes)
        ));
      }
      
      // setState(() {
        // final tempImage = File(image.path);
        // this.image = tempImage;
      // });
    } on PlatformException catch (e) {
      print("Failed to pick an image: $e");
    }
    setState(() {
      pickedImage = image;
    });
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
        /*LoadingFilling.square(
            borderColor: Colors.teal,
            size: 100,
          )*/

      ),
    );
  }
}
