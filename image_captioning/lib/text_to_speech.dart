import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_captioning/shared_components.dart';

class TextTSpeech extends StatelessWidget{
  @override
  FlutterTts flutterTts = FlutterTts();
  void textToSpeech() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1);
    await flutterTts.speak('hello');

  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            child: defaultButton(
                text: 'speak',
                function: textToSpeech,
            ),
          ),
        ),
      ),
    );
  }
}