import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_captioning/slideAnimation.dart';
import 'home.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatelessWidget {
   IntroScreen({Key? key});

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
      footer: ElevatedButton(
        onPressed: () {
          // On button pressed
        },
        child: const Text("Let's Go!"),
      ),
    )];


  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: listPagesViewModel,
      showSkipButton: true,
      showNextButton: false,
      skip: const Text("Skip"),
      next: const Text('Next'),
      done: const Text("Done",style: TextStyle(fontWeight: FontWeight.w700)),
      onDone: () {
        Navigator.of(context).pushReplacement(SlideAnimation(
          page: homeState(),
          beginX: 0,
          beginY: 0,
          endX: 0,
          endY: 0,
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
    );
  }
}
