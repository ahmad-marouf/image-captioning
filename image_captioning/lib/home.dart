import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_captioning/slideAnimation.dart';
import 'firstScene.dart';
import 'camera_page.dart';
import 'package:camera/camera.dart';

import 'package:image_captioning/model/decoder.dart';
import 'package:image_captioning/model/encoder.dart';

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
          SnackBar(
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
      appBar: AppBar(
        title: Text('Hello',
            style: TextStyle(
                fontFamily: "CarterOne", fontSize: 50, color: Colors.black)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 10,
        shadowColor: Colors.teal,
        backgroundColor: Colors.tealAccent,
        //shape: StadiumBorder(),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('my title'),
                    content: Text('the body of the help icon'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'))
                    ],
                  ));
            },
            icon: const Icon(Icons.question_mark),
            color: Colors.black,
            tooltip: 'HELP',
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/image/backgorund_image.jpeg'),
                fit: BoxFit.cover)),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(SlideAnimation(
                    page: const firstScene(),
                    beginX: 1,
                    ));
              },
              child:  Text('Second Screen'),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
            ElevatedButton(
              onPressed: () async {
                 await availableCameras().then((value) =>
                        Navigator.of(context).push(SlideAnimation(
                            beginX: 1,
                            page: CameraPage(cameras: value))
                        ),
                    );
              },
              child: Text('Second Screen'),
              style: ElevatedButton.styleFrom(),
            ),
            ElevatedButton(
              onPressed: () async {
                // Navigator.pushNamed(context, 'first');
                Encoder encoder = await Encoder.instance;
                Decoder decoder = await Decoder.instance;
                var result = await encoder.predict('image/test_model_1.jpg');
                var caption = await decoder.predict(result!);
                print(caption);
              },
              child: Text('Second Screen'),
              style: ElevatedButton.styleFrom(),
            )
          ],
        ),
      ),
    );
  }
}