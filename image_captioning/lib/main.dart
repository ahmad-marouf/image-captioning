import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/decoder.dart';
import 'model/encoder.dart';
import 'pages/IntroScreen.dart';
import 'pages/Home/home.dart';

void main(){
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const ConstructionApp());
}

class ConstructionApp extends StatelessWidget{
  const ConstructionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capture Image Generator',
      debugShowCheckedModeBanner: false,
      home:  Splash(),
      builder: EasyLoading.init(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal
      ),
    );
  }
}

class Splash extends StatefulWidget {
   Splash({super.key});

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  late Encoder encoder;
  late Decoder decoder;

  Future checkFirstSeen() async {
    encoder = await Encoder.instance;
    decoder = await Decoder.instance;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) =>  const HomeState()));
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) =>  IntroScreen()));
    }

    /*Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => IntroScreen()
        )
    );*/

  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    checkFirstSeen();
    return const MaterialApp(
      home: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}



