import 'package:flutter/material.dart';
import 'package:liveness/models/liveness/condition/liveness_condition.dart';

class LivenessEyeBlink extends LivenessCondition {
  static const double _maxRangeCenterFace = 10;

  LivenessEyeBlink({
    String instruction = "Cligner des yeux lentement",
  }) : super(
          name: 'EyeBlink',
          rangesConditionsList: [
            _centerFaceCondition()
              ..add(
                LivenessRangeCondition(
                  range: const RangeValues(0, 0.05),
                  optimalValue: 0,
                  analyseFaceValue: FaceMap.leftEyeOpenProbability,
                ),
              ),
            _centerFaceCondition()
              ..add(
                LivenessRangeCondition(
                  range: const RangeValues(0.8, 1),
                  optimalValue: 1,
                  analyseFaceValue: FaceMap.leftEyeOpenProbability,
                ),
              ),
            _centerFaceCondition()
              ..add(
                LivenessRangeCondition(
                  range: const RangeValues(0, 0.05),
                  optimalValue: 0,
                  analyseFaceValue: FaceMap.rightEyeOpenProbability,
                ),
              ),
            _centerFaceCondition()
              ..add(
                LivenessRangeCondition(
                  range: const RangeValues(0.8, 1),
                  optimalValue: 1,
                  analyseFaceValue: FaceMap.rightEyeOpenProbability,
                ),
              ),
          ],
          instruction: instruction,
        );

  static List<LivenessRangeCondition> _centerFaceCondition() {
    return [
      LivenessRangeCondition(
        range: const RangeValues(
          -_maxRangeCenterFace,
          _maxRangeCenterFace,
        ),
        optimalValue: 0,
        analyseFaceValue: FaceMap.headEulerAngleX,
      ),
      LivenessRangeCondition(
        range: const RangeValues(
          -_maxRangeCenterFace,
          _maxRangeCenterFace,
        ),
        optimalValue: 0,
        analyseFaceValue: FaceMap.headEulerAngleY,
      ),
      LivenessRangeCondition(
        range: const RangeValues(
          -_maxRangeCenterFace,
          _maxRangeCenterFace,
        ),
        optimalValue: 0,
        analyseFaceValue: FaceMap.headEulerAngleZ,
      )
    ];
  }
}
