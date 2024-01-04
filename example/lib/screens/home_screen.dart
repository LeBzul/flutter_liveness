import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:liveness/controllers/face_controller.dart';

import 'liveness_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool removeBlurResult = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 0),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(50, 8, 25, 6),
                child: Text(
                  'Selection du model :',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Center(
                child: AnimatedToggleSwitch<FaceNet>.size(
                  current: FaceController.selectedFaceNet,
                  values: const [
                    FaceNet.facenet,
                    FaceNet.mobileFaceNet,
                  ],
                  iconOpacity: 0.2,
                  indicatorSize: Size.fromWidth((MediaQuery.of(context).size.width) / 2 - 50),
                  customIconBuilder: (context, local, global) => Text(
                    local.value.name,
                    style: TextStyle(
                      color: Color.lerp(
                        Colors.black,
                        Colors.white,
                        local.animationValue,
                      ),
                    ),
                  ),
                  borderWidth: 4.0,
                  iconAnimationType: AnimationType.onHover,
                  style: ToggleStyle(
                    indicatorColor: Colors.teal,
                    borderColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                  selectedIconScale: 1.0,
                  onChanged: (b) => setState(() => FaceController.selectedFaceNet = b),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  width: Size.fromWidth((MediaQuery.of(context).size.width) - 100).width,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LivenessScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.face,
                      color: Colors.white,
                    ),
                    label: const Text("Start Liveness"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
