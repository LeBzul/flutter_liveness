import 'package:liveness/models/condition/liveness/liveness_condition.dart';

import 'liveness_turn_face.dart';

class LiveNessTurnLeftFace extends LivenessCondition {
  LiveNessTurnLeftFace({
    String instruction = "Tourner la tête lentement vers la gauche",
  }) : super(
          rangesConditionsList: LiveNessTurnFace.directionConditions(
            LiveNessTurnFaceDirection.left,
          ),
          instruction: instruction,
        );
}
