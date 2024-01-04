import 'package:flutter/material.dart';
import 'package:liveness/models/condition/liveness/liveness_condition.dart';

class LivenessEyeBlink extends LivenessCondition {
  LivenessEyeBlink({
    String instruction = "Cligner des yeux lentement",
  }) : super(
          rangesConditionsList: [
            [
              LivenessRangeCondition(
                range: RangeCondition(
                  value: const RangeValues(0, 0.2),
                  optimalValue: 0,
                ),
                analyseFaceValue: FaceMap.leftEye,
              ),
            ],
            [
              LivenessRangeCondition(
                range: RangeCondition(
                  value: const RangeValues(0.8, 1),
                  optimalValue: 1,
                ),
                analyseFaceValue: FaceMap.leftEye,
              ),
            ],
            [
              LivenessRangeCondition(
                range: RangeCondition(
                  value: const RangeValues(0, 0.2),
                  optimalValue: 0,
                ),
                analyseFaceValue: FaceMap.rightEye,
              ),
            ],
            [
              LivenessRangeCondition(
                range: RangeCondition(
                  value: const RangeValues(0.8, 1),
                  optimalValue: 1,
                ),
                analyseFaceValue: FaceMap.rightEye,
              ),
            ]
          ],
          instruction: instruction,
        );
}
