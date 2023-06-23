import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:image_captioning/components/slideAnimation.dart';
import 'Home/home.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      title: "Welcome to Image Caption Generator (ICG) application",
      body: "Our team presents to you an application that can help blind people visualize their surroundings",
      image: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const Image(image: AssetImage("assets/image/Team.jpg"),
            fit: BoxFit.fill,
          ),
        ),
      ),
    ),
    PageViewModel(
      title: "Methods for getting input image for captioning",
      body: "1. Get input image from camera embedded in glasses.\n"
          "2. Get input image from phone's camera.\n"
          "3. Get input image from phone's gallery.",
      image: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const Image(image: AssetImage("assets/image/methods definition.jpg"),
            fit: BoxFit.fill,
          ),
        ),
      ),
    ),
    PageViewModel(
        title: "That's all, hope you find the app useful, Enjoy!",
        body: "",
        image: const Center(
          child: Icon(Icons.waving_hand, size: 100),
        ),
        decoration: const PageDecoration(
            titleTextStyle: TextStyle(fontSize: 30),
            imagePadding: EdgeInsets.only(bottom: 30))
    )];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(
        pages: listPagesViewModel,
        showSkipButton: true,
        showNextButton: false,
        skip: const GlowText('skip'),
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
