import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_captioning/shared_coponents.dart';
import 'package:image_captioning/side_bar_screen.dart';
import 'package:image_captioning/slideAnimation.dart';
import 'package:rive/rive.dart';
import 'firstScene.dart';
import 'camera_page.dart';
import 'package:camera/camera.dart';
import 'package:image_captioning/model/decoder.dart';
import 'package:image_captioning/model/encoder.dart';

import 'gallery_screen.dart';

class homeState extends StatefulWidget {
  const homeState({Key? key}) : super(key: key);

  @override
  State<homeState> createState() => _homeState();
}

class _homeState extends State<homeState> {
  DateTime? _currentBackPressTime;

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          DateTime now = DateTime.now();

          if (_currentBackPressTime == null ||
              now.difference(_currentBackPressTime!) > Duration(seconds: 2)) {
            _currentBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Press back button again to exit'),
              ),
            );
            return false;
          }
          return true;
        },
        child: homeScene(),
      );
}

class homeScene extends StatelessWidget {
  const homeScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
      drawer: Container(color: Colors.black,
          child: SideBar()),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
            'Hello',
            style: TextStyle(
                fontFamily: "CarterOne",
                fontSize: 50,
                color: Colors.white)
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('my title'),
                        content: const Text('the body of the help icon'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'))
                        ],
                      ));
            },
            icon: const Icon(Icons.question_mark),
            color: Colors.white,
            tooltip: 'HELP',
          )
        ],
      ),
      body: Stack(
          fit: StackFit.expand,
          children: [
        const RiveAnimation.asset(
          "assets/rive/shape.riv",
          fit: BoxFit.cover,
        ),
        Positioned.fill(
            child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10),
          child: SizedBox(),
        )),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            card(
                text: 'External devices',
                icon: Icons.devices_other,
                navigator: () {
                  Navigator.of(context).push(SlideAnimation(
                    page: const firstScene(),
                    beginX: 1,
                  ));
                }),
            const SizedBox(height: 15),
            card(
                text: 'Camera',
                icon: Icons.camera,
                navigator: () async {
                  await availableCameras().then(
                    (value) => Navigator.of(context).push(SlideAnimation(
                        beginX: 1, page: CameraPage(cameras: value)
                    )),
                  );
                }),
            const SizedBox(height: 15),
            card(
                text: 'Gallery',
                icon: Icons.image,
                navigator:() {Navigator.of(context).push(SlideAnimation(beginX: 1,page: GalleryScreen())); }/*() async {
                  Encoder encoder = await Encoder.instance;
                  Decoder decoder = await Decoder.instance;
                  var result = await encoder.predict('image/test_model_1.jpg');
                  var caption = await decoder.predict(result!);
                  print(caption);
                }*/),
          ],
        ),
      ]),
    );
  }
}
