import 'package:flutter/material.dart';
import 'package:liveness/models/condition/liveness/liveness_condition.dart';

class LivenessCenterFace extends LivenessCondition {
  double maxRange;

  LivenessCenterFace({
    this.maxRange = 5,
    String instruction = "Mettez votre tête bien droite",
  }) : super(
          rangesConditionsList: [
            [
              LivenessRangeCondition(
                range: RangeCondition(
                  value: RangeValues(
                    -maxRange,
                    maxRange,
                  ),
                  optimalValue: 0,
                ),
                analyseFaceValue: FaceMap.faceAngleX,
              ),
              LivenessRangeCondition(
                range: RangeCondition(
                  value: RangeValues(
                    -maxRange,
                    maxRange,
                  ),
                  optimalValue: 0,
                ),
                analyseFaceValue: FaceMap.faceAngleY,
              ),
              LivenessRangeCondition(
                range: RangeCondition(
                  value: RangeValues(
                    -maxRange,
                    maxRange,
                  ),
                  optimalValue: 0,
                ),
                analyseFaceValue: FaceMap.faceAngleZ,
              ),
            ],
          ],
          instruction: instruction,
        );
}
