import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_captioning/components/shared_components.dart';
import 'package:image_captioning/pages/Home/side_bar_screen.dart';
import 'package:image_captioning/components/slideAnimation.dart';
import 'package:rive/rive.dart';
import '../../external_connection/esp_wifi.dart';
import '../../model/decoder.dart';
import '../../model/encoder.dart';
import '../camera/camera_page.dart';
import 'package:camera/camera.dart';
import '../gallery/gallery_screen.dart';

class HomeState extends StatefulWidget {
  const HomeState({Key? key}) : super(key: key);

  @override
  State<HomeState> createState() => _HomeState();
}

class _HomeState extends State<HomeState> with TickerProviderStateMixin{
  late final AnimationController _controller;
  late final Animation<double> _animation;
  DateTime? _currentBackPressTime;
 /* late Encoder encoder;
  late Decoder decoder;*/

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          DateTime now = DateTime.now();

          if (_currentBackPressTime == null ||
              now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
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
        child: HomeScene(animation: _animation,),
      );

  @override
  void initState(){
    /*
      encoder = () async{
        await Encoder.instance;
      } as Encoder;
      decoder = () async{
        await Decoder.instance;
      } as Decoder;*/

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    Timer(
        const Duration(milliseconds: 200),
            (){_controller.forward();
        });
    super.initState();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
}

class HomeScene extends StatelessWidget {
  final  Animation<double> animation;
  const HomeScene({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Container(
          color: Colors.black,
          child: const SideBar()
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Builder(
            builder: (context){
              return IconButton(
                  onPressed: ()=>Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu));
            },
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        /*actions: [
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
        ],*/
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
              child: const SizedBox(),
        )),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0,0.025),
            end: const Offset(0,0)
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const SizedBox(height: 25),
                const Text(
                    'Image Caption Generator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Goldman",
                        fontSize: 45,
                        color: Colors.white)
                ),
                const SizedBox(height: 15),
                const Text(
                    'Select Capture Method',
                    style: TextStyle(
                        fontFamily: "Goldman",
                        fontSize: 25,
                        color: Colors.white
                    )
                ),
                const SizedBox(height: 10),
                card(
                    text: 'External devices',
                    icon: Icons.devices_other,
                    navigator: () {
                      Navigator.of(context).push(SlideAnimation(
                        page: const WifiCheck(),
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
                    navigator:() {Navigator.of(context).push(
                        SlideAnimation(
                            beginX: 1,
                            page: GalleryScreen()
                        ));
                    })
              ]),
          ),
        ),
      ]),
    );
  }
}
