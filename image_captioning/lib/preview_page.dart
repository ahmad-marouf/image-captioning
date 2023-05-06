import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

import 'package:flutter/services.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:image_captioning/slideAnimation.dart';
import 'package:image_captioning/shared_components.dart';
import 'package:image_captioning/model/encoder.dart';
import 'package:image_captioning/model/decoder.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CaptionGenerator extends StatefulWidget {
  const CaptionGenerator({Key? key, required this.imageBytes}) : super(key: key);

  final Uint8List imageBytes;

  @override
  State<CaptionGenerator> createState() => _CaptionGeneratorState();
}

class _CaptionGeneratorState extends State<CaptionGenerator> {

  void _generateCaption() async {
    Encoder encoder = await Encoder.instance;
    Decoder decoder = await Decoder.instance;
    String? caption;


    ByteBuffer? features = await encoder.predict(widget.imageBytes);
    if (features != null) {
      caption = await decoder.predict(features);
    }

    imageLib.Image? img = imageLib.decodeImage(widget.imageBytes);
    Image image = Image.memory(
      widget.imageBytes,
      fit: BoxFit.fitWidth,
      width: img?.width.toDouble(),
      height: img?.height.toDouble(),
    );

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
          SlideAnimation(
              beginX: 1,
              page: PreviewPage(
                image: image,
                caption: caption!,
              )
          )
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _generateCaption();
    // imageLib.Image? img = imageLib.decodeImage(widget.imageBytes);
    // print("${img?.width.toDouble()}x${img?.height.toDouble()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
          child: LoadingFilling.square(
            borderColor: Colors.teal,
            size: 100,
          )
      ),
    );
  }
}



class PreviewPage extends StatelessWidget {
  PreviewPage({Key? key, required this.image, required this.caption}) : super(key: key);

  final Image image;
  final String caption;
  final FlutterTts flutterTts = FlutterTts();

  _playSound() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1);
    await flutterTts.speak(caption);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.bottom]);

    _playSound();

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Column(
          children: [
            SizedBox(
              height: (image.height! > 500) ? 0 : 200,
            ),
            // FractionallySizedBox(
            //   heightFactor: (image.height! > image.width!) ? 0 : 0.1,
            // ),
            Expanded(
              flex: 4,
              child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      // height: 200,
                      child: InnerShadow(
                        shadows: const [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(0, 0),
                            blurRadius: 10,
                          )
                        ],
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: image,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20.0,
                      top: (image.height! > 500) ? 550 : 200,
                      width: 45.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade900,
                            foregroundColor: Colors.teal,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            )
                        ),
                        child: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Positioned(
                      right: 20.0,
                      top:  (image.height! > 500) ? 550 : 200,
                      width: 45.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade900,
                            foregroundColor: Colors.teal,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            )
                        ),
                        child: const Icon(Icons.home_rounded),
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                    ),
                  ]
              ),
            ),
            SizedBox(
              height: (image.height! > 500) ? 24 : 0,
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "Goldman",
                    color: Colors.white,
                    fontSize: 20.0
                  ),
                ),
              ),
            ),
          ]),
    );
  }
}
