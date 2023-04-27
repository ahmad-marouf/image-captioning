
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_captioning/shared_coponents.dart';
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
      if(image== null) return;
      
      setState(() {
        final tempImage = File(image!.path);
        this.image = tempImage;
      });
    } on PlatformException catch (e) {
      print("Failed to pick an image: $e");
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: defaultButton(
            width: 200,
              height: 200,
              text: 'pick image',
              function: () {
                pickImage();

              },
          ),
        ),
      ),
    );
  }
}
