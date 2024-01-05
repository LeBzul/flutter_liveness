import 'package:liveness/models/liveness/condition/liveness_condition.dart';

import 'liveness_face_turn.dart';

class LivenessFaceTurnRight extends LivenessCondition {
  LivenessFaceTurnRight({
    String instruction = "Tourner la tête lentement vers la droite",
  }) : super(
          rangesConditionsList: LivenessFaceTurn.directionConditions(
            LivenessFaceDirectionTurn.right,
          ),
          instruction: instruction,
        );
}
