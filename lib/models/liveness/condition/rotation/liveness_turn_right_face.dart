import 'package:liveness/models/liveness/condition/liveness_condition.dart';

import 'liveness_turn_face.dart';

class LivenessTurnRightFace extends LivenessCondition {
  LivenessTurnRightFace({
    String instruction = "Tourner la tête lentement vers la droite",
  }) : super(
          name: 'TurnRight',
          rangesConditionsList: LiveNessTurnFace.directionConditions(
            LiveNessTurnFaceDirection.right,
          ),
          instruction: instruction,
        );
}
