import 'package:flutter/material.dart';
import 'package:liveness/models/condition/liveness/liveness_condition.dart';

import 'liveness_turn_face.dart';

class LivenessCenterFace extends LivenessCondition with LiveNessTurnFace {
  double maxRange;

  LivenessCenterFace({
    this.maxRange = 5,
    String instruction = "Mettez votre tête bien droite",
  }) : super(
          name: 'CenterFace',
          rangesConditionsList: [
            [
              LivenessRangeCondition(
                range: RangeValues(
                  -maxRange,
                  maxRange,
                ),
                optimalValue: 0,
                analyseFaceValue: FaceMap.headEulerAngleX,
              ),
              LivenessRangeCondition(
                range: RangeValues(
                  -maxRange,
                  maxRange,
                ),
                optimalValue: 0,
                analyseFaceValue: FaceMap.headEulerAngleY,
              ),
              LivenessRangeCondition(
                range: RangeValues(
                  -maxRange,
                  maxRange,
                ),
                optimalValue: 0,
                analyseFaceValue: FaceMap.headEulerAngleZ,
              ),
            ],
          ],
          instruction: instruction,
        );
}
