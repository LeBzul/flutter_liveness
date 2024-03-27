import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:liveness/liveness.dart';

class LivenessScreen extends StatefulWidget {
  const LivenessScreen({Key? key}) : super(key: key);

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  LivenessCondition? actualStep;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: LivenessWidget(
            livenessController: LivenessController(
              liveNessStepConditions: [
                LivenessFaceCenter(instruction: "Mettez votre tête bien droite en face de l'ecran."),
                LivenessFaceTurnLeft(),
                LivenessFaceTurnRight(),
              ],
              liveNessPassiveStepConditions: [
                LivenessEyeBlink(),
              ],
              livenessSuccessResult: (controller, faceRecognitions) async {
                List<Map<String, String>> base64ImagesList = [];
                for (var faceRecognition in faceRecognitions) {
                  // Convertir l'image en une chaîne Base64
                  String base64String = base64Encode(
                    img.encodePng(
                      await faceRecognition.faceImage.generateCropFaceWithRatio(),
                    ),
                  );
                  Map<String, String> base64Image = {
                    'base64': base64String,
                    'extension': 'png',
                  };
                  print(base64String);
                  base64ImagesList.add(base64Image);
                }

                //    Navigator.pop(context);
              },
              livenessErrorResult: (controller, errorConditions) {
                controller.reset();
              },
              stepConditionChange: (controller, actualCondition, stepCount, maxStep) {},
              cameraError: () {},
            ),
          ),
        ),
      ),
    );
  }
}
