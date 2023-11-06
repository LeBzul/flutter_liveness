import 'package:liveness/models/liveness/condition/liveness_condition.dart';

import 'liveness_turn_face.dart';

class LiveNessTurnLeftFace extends LivenessCondition {
  LiveNessTurnLeftFace({
    String instruction = "Tourner la tête lentement vers la gauche",
  }) : super(
          name: 'TurnLeft',
          rangesConditionsList: LiveNessTurnFace.directionConditions(
            LiveNessTurnFaceDirection.left,
          ),
          instruction: instruction,
        );
}
