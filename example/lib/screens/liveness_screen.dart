import 'package:example/screens/recognizing_screen.dart';
import 'package:flutter/material.dart';
import 'package:liveness/liveness.dart';
import 'package:liveness/models/liveness/condition/liveness_condition.dart';

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
            liveNessActiveConditions: [
              LivenessCenterFace(),
              LiveNessTurnLeftFace(),
              LivenessTurnRightFace(),
            ],
            liveNessPassiveConditions: [
              LivenessEyeBlink(),
            ],
            livenessSuccessResult: (liveness, faces) {
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
            actualLivenessChange: (actualLivenessCondition) {
              actualStep = actualLivenessCondition;
              setState(() {});
            },
            instructionsOverlay: buildInstructionOverlay(),
          ),
        ),
      ),
    );
  }

  Widget buildInstructionOverlay() {
    return Container(
      color: Colors.white.withAlpha(100),
      width: 50,
      height: 100,
      child: Center(
        child: Text('${actualStep?.instruction}'),
      ),
    );
  }
}
