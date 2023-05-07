
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_captioning/preview_page.dart';
import 'package:image_captioning/shared_components.dart';
import 'package:image_captioning/slideAnimation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:rive/rive.dart';

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
    }

  @override
  Widget build(BuildContext context) {
    pickImage();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: const Center(
          child: RiveAnimation.asset('assets/rive/loader.riv',
              fit: BoxFit.contain)
        /*LoadingFilling.square(
            borderColor: Colors.teal,
            size: 100,
          )*/

      ),
    );
  }
}
