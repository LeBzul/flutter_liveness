import 'package:flutter/material.dart';
import 'package:liveness/models/liveness/condition/liveness_condition.dart';

class LivenessFaceCenter extends LivenessCondition {
  double maxRange;

  LivenessFaceCenter({
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
