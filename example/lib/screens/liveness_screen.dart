import 'package:example/screens/recognizing_screen.dart';
import 'package:flutter/material.dart';
import 'package:liveness/liveness.dart';

class LivenessScreen extends StatefulWidget {
  const LivenessScreen({Key? key}) : super(key: key);

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  RecognitionCondition? actualStep;

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
            liveNessActiveConditions: [
              LivenessCenterFace(),
              LiveNessTurnLeftFace(),
              LivenessTurnRightFace(),
            ],
            liveNessPassiveConditions: [
              LivenessEyeBlink(),
            ],
            livenessSuccessResult: (liveness, faces, distance) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecognizingScreen(
                    liveness: liveness,
                    faceRecognitions: faces,
                  ),
                ),
              );
            },
            livenessErrorResult: (liveness, errorConditions) {
              print("==================");
              for (var condition in errorConditions) {
                print(condition.name);
                condition.reset();
              }
              setState(() {});
            },
            stepConditionChange: (actualLivenessCondition, step, maxStep) {
              actualStep = actualLivenessCondition;
              setState(() {});
            },
            identityCondition: IdentityCondition(
              name: 'Identity verification',
              imagesBase64: ['SET_WITH_CNI_IMAGE_BASE_64'],
              instruction: 'Wait',
            ),
          ),
        ),
      ),
    );
  }
}
