import 'package:liveness/models/liveness/condition/liveness_condition.dart';

import 'liveness_face_turn.dart';

class LivenessFaceTurnLeft extends LivenessCondition {
  LivenessFaceTurnLeft({
    String instruction = "Tourner la tête lentement vers la gauche",
  }) : super(
          rangesConditionsList: LivenessFaceTurn.directionConditions(
            LivenessFaceDirectionTurn.left,
          ),
          instruction: instruction,
        );
}
