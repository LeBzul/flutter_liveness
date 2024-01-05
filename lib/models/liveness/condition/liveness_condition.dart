import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:liveness/models/face_recognizer/model/face.dart';
import 'package:liveness/models/liveness/condition/liveness_condition_result.dart';

abstract class LivenessCondition {
  String instruction;

  List<List<LivenessRangeCondition>> rangesConditionsList;
  Map<int, LivenessConditionResult?> conditionResult = <int, LivenessConditionResult?>{};
  bool get isValidated => !conditionResult.containsValue(null);

  LivenessCondition({
    required this.rangesConditionsList,
    required this.instruction,
  }) {
    initConditionResult();
  }

  void reset() {
    initConditionResult();
  }

  void initConditionResult() {
    int i = 0;
    conditionResult = <int, LivenessConditionResult?>{};
    for (var _ in rangesConditionsList) {
      conditionResult.putIfAbsent(i++, () => null);
    }
  }

  void updateFace(
    FaceImage faceImage,
  ) {
    int indexRangesConditions = 0;
    for (var rangesConditionList in rangesConditionsList) {
      List<double> probability = [];

      int indexRange = 0;
      for (var rangeCondition in rangesConditionList) {
        double? value = FaceMap.getValue(
          rangeCondition.analyseFaceValue,
          faceImage.face,
        );
        if (value != null && value < rangeCondition.range.value.end && value > rangeCondition.range.value.start) {
          LivenessConditionResult? lastConditionResult =
              conditionResult.containsKey(indexRangesConditions) ? conditionResult[indexRangesConditions] : null;
          if (lastConditionResult == null ||
              rangeCondition.range.optimalValue.abs() - lastConditionResult.value[indexRange].abs() >
                  rangeCondition.range.optimalValue.abs() - value.abs()) {
            probability.add(value);
          }
        }
        indexRange++;
      }

      if (probability.length == rangesConditionList.length) {
        conditionResult[indexRangesConditions] = LivenessConditionResult(
          value: probability,
          faceImage: faceImage,
        );
      }
      indexRangesConditions++;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rangesConditionsMap = <String, dynamic>{};
    for (var rangeCondition in rangesConditionsList) {
      for (var element in rangeCondition) {
        rangesConditionsMap.putIfAbsent(
          '${rangesConditionsMap.length}',
          () => element.toJson(),
        );
      }
    }

    Map<String, dynamic> conditionResultMap = <String, dynamic>{};
    conditionResult.forEach((key, value) {
      conditionResultMap.putIfAbsent(
        '$key',
        () => value?.toJson(),
      );
    });

    return <String, dynamic>{
      'instruction': instruction,
      'rangesConditions': rangesConditionsMap,
      'conditionResult': conditionResultMap,
    };
  }
}

class RangeCondition {
  RangeValues value;
  double optimalValue;

  RangeCondition({
    required this.value,
    required this.optimalValue,
  });
}

class LivenessRangeCondition {
  RangeCondition range;
  FaceMap analyseFaceValue;
  LivenessRangeCondition({
    required this.range,
    required this.analyseFaceValue,
  });

  Map<String, dynamic> toJson() => {
        'analyseFaceValue': analyseFaceValue.name,
        'range': <String, dynamic>{
          'start': range.value.start,
          'end': range.value.end,
        },
      };
}

enum FaceMap {
  leftEye,
  rightEye,
  faceAngleX,
  faceAngleY,
  faceAngleZ;

  static double? getValue(FaceMap faceMap, Face face) {
    // MlKit doc :
    // https://developers.google.com/ml-kit/reference/swift/mlkitfacedetection/api/reference/Classes/Face?hl=fr
    switch (faceMap) {
      case FaceMap.leftEye:
        return face.leftEyeOpenProbability;
      case FaceMap.rightEye:
        return face.rightEyeOpenProbability;
      case FaceMap.faceAngleX:
        return face.headEulerAngleX;
      case FaceMap.faceAngleY:
        return face.headEulerAngleY;
      case FaceMap.faceAngleZ:
        return face.headEulerAngleZ;
    }
  }
}
