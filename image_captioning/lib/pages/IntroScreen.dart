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
      title: "Welcome to ICG application",
      body: "Our team represent to you application can help many blind people to define objects in their way",
      image: const Center(
        child: Image(image: AssetImage("assets/image/Team.jpg"),
          fit: BoxFit.fill,
        width: 250,
        height: 200,)
      ),
    ),
    PageViewModel(
      title: "Methods of image caption in our App",
      body: "1. Image caption using camera of glasses.\n"
          "2. Image caption using camera of mobile phone.\n"
          "3. Image caption using the gallery of mobile phone.",
      image: const Center(
        child: Image(image: AssetImage("assets/image/methods definition.jpg"),
        fit: BoxFit.fill,
        width: 300,),
      ),
    ),
    PageViewModel(
      title: "That's all, hope you find app is useful, Enjoy!",
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
