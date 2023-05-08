import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_captioning/main.dart';
import 'package:image_captioning/shared_components.dart';
import 'package:image_captioning/slideAnimation.dart';
import 'home.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatefulWidget {
   const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      title: "Title of introduction page",
      body: "Welcome to the app! This is a description of how it works.",
      image: const Center(
        child: Icon(Icons.waving_hand, size: 50.0),
      ),
    ),
    PageViewModel(
      title: "Title of blue page",
      body: "Welcome to the app! This is a description on a page with a blue background.",
      image: Center(
        child: Image.network("https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg", height: 175.0),
      ),
      decoration: const PageDecoration(
        pageColor: Colors.blue,
      ),
    ),PageViewModel(
      title: "Title of orange text and bold page",
      body: "This is a description on a page with an orange title and bold, big body.",
      image: const Center(
        child: Text("👋", style: TextStyle(fontSize: 100.0)),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(color: Colors.orange),
        bodyTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0),
      ),
    ),
    PageViewModel(
      title: "Title of custom button page",
      body: "This is a description on a page with a custom button below.",
      footer: Padding(
        padding: EdgeInsets.all(20),
        child: SizedBox(),
      ),
    )];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(
        pages: listPagesViewModel,
        showSkipButton: true,
        showNextButton: false,
        skip: const Text("Skip"),
        next: const Text('Next'),
        done: const Text("Done",
            style: TextStyle(
                fontWeight: FontWeight.w700)
        ),
        onDone: () {
          Navigator.of(context).pushReplacement(SlideAnimation(
            page: const HomeState(),
            beginY: 1,
          ));
        },
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0)
          ),
        ),
      ),
    );
  }
}
