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
            livenessController: LivenessController(
              liveNessStepConditions: [],
              liveNessPassiveStepConditions: [
                LivenessFaceCenter(instruction: "Mettez votre tête bien droite en face de l'ecran."),
                LivenessFaceTurnLeft(),
                LivenessFaceTurnRight(),
                LivenessEyeBlink(),
              ],
              livenessSuccessResult: (controller, faceRecognitions) {
                Navigator.pop(context);
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
