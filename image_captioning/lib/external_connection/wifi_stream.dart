import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';

import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:image_captioning/components/shared_components.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:image_captioning/components/slideAnimation.dart';
import 'package:image_captioning/external_connection/esp_wifi.dart';
import 'package:image_captioning/pages/preview_page.dart';


class WifiStream extends StatefulWidget {
  final WebSocketChannel channel;

  const WifiStream({Key? key, required this.channel}) : super(key: key);

  @override
  WifiStreamState createState() => WifiStreamState();
}

class WifiStreamState extends State<WifiStream> {
  double newVideoSizeWidth = 640;
  double newVideoSizeHeight = 480;

  bool autoCapture = true;
  late Timer timer;

  final _globalKey = GlobalKey();



  @override
  void initState() {
    super.initState();
    print("AutoCapture: $autoCapture");
    if (autoCapture) {
      timer = Timer.periodic(const Duration(seconds: 10), (timer)  async{
        await takeScreenShot();
      });
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF121212),
        child: StreamBuilder(
          stream: widget.channel.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Future.delayed(const Duration(milliseconds: 100)).then((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const WifiCheck()));
              });
            }
            if (!snapshot.hasData) {
              print("${snapshot.hasError}, ${snapshot.error}");
              print(snapshot.connectionState);
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            } else {
              return Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 2, color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const SizedBox(
                          width: double.infinity,
                          child: Text(
                            "ESP-32 CAM \nLive Feed",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40.0,
                                fontFamily: "Goldman"
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 270,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Transform.rotate(
                        angle: -pi/2,
                        child: CustomPaint(
                          foregroundPainter: BorderPainter(
                              Colors.white,
                              30
                          ),
                          child: RepaintBoundary(
                            key: _globalKey,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.memory(
                                snapshot.data,
                                gaplessPlayback: true,
                                width: newVideoSizeWidth,
                                height: newVideoSizeHeight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.17,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        color: Colors.black),
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: takeScreenShot,
                          iconSize: 50,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.circle, color: Colors.white),
                        ),
                        SwitchListTile(
                            title: const Text(
                              'Auto Capture',
                              style: TextStyle(
                                  fontFamily: "Nunito",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            value: autoCapture,
                            onChanged: (bool value) {
                              print(value);
                              if (value) {
                                timer = Timer.periodic(const Duration(seconds: 10), (timer)  async{
                                  await takeScreenShot();
                                });
                              } else {
                               timer.cancel();
                              }
                              setState(() {
                                autoCapture = value;
                              });
                            }
                        )
                      ],

                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  takeScreenShot() async {
    final RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();

    if (mounted) {
      Navigator.of(context)
          .push(SlideAnimation(
            beginX: 1,
            page: CaptionGenerator(imageBytes: pngBytes, rotateImage: true, autoCapture: autoCapture)
      ));
    }

  }


}