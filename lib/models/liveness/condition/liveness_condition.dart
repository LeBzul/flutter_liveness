import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:liveness/models/face.dart';

import 'liveness_condition_result.dart';

abstract class LivenessCondition {
  String instruction;
  String name;

  List<List<LivenessRangeCondition>> rangesConditionsList;

  Map<int, LivenessConditionResult?> conditionResult = <int, LivenessConditionResult?>{};

  LivenessCondition({
    required this.rangesConditionsList,
    required this.name,
    required this.instruction,
  }) {
    _initConditionResult();
  }

  bool get alive => !conditionResult.containsValue(null);

  void _initConditionResult() {
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
    for (var rangesList in rangesConditionsList) {
      List<double> probability = [];

      int indexRange = 0;
      for (var range in rangesList) {
        double? value = FaceMap.getValue(
          range.analyseFaceValue,
          faceImage.face,
        );
        if (value != null && value < range.range.end && value > range.range.start) {
          LivenessConditionResult? lastConditionResult =
              conditionResult.containsKey(indexRangesConditions) ? conditionResult[indexRangesConditions] : null;
          if (lastConditionResult == null ||
              range.optimalValue.abs() - lastConditionResult.value[indexRange].abs() >
                  range.optimalValue.abs() - value.abs()) {
            probability.add(value);
          }
        }
        indexRange++;
      }

      if (probability.length == rangesList.length) {
        conditionResult[indexRangesConditions] = LivenessConditionResult(
          name: name,
          value: probability,
          faceImage: faceImage,
        );
      }
      indexRangesConditions++;
    }
  }
/*
  void update(
    Face face,
    img.Image image,
    FaceRecognition recognition,
  ) {
    int indexRangesConditions = 0;
    for (var rangesList in rangesConditionsList) {
      List<double> probability = [];

      int indexRange = 0;
      for (var range in rangesList) {
        double? value = FaceMap.getValue(range.analyseFaceValue, face);
        if (value != null && value < range.range.end && value > range.range.start) {
          LivenessConditionResult? lastConditionResult =
              conditionResult.containsKey(indexRangesConditions) ? conditionResult[indexRangesConditions] : null;
          if (lastConditionResult == null ||
              range.optimalValue.abs() - lastConditionResult.value[indexRange].abs() >
                  range.optimalValue.abs() - value.abs()) {
            probability.add(value);
          }
        }
        indexRange++;
      }

      if (probability.length == rangesList.length) {
        conditionResult[indexRangesConditions] = LivenessConditionResult(
          name: name,
          value: probability,
          //  recognition: recognition,
          imageResult: image,
        );
      }
      indexRangesConditions++;
    }
  }*/

  void reset() {
    _initConditionResult();
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
      'name': name,
      'instruction': instruction,
      'rangesConditions': rangesConditionsMap,
      'conditionResult': conditionResultMap,
    };
  }
}

class LivenessRangeCondition {
  RangeValues range;
  double optimalValue;
  FaceMap analyseFaceValue;
  LivenessRangeCondition({
    required this.range,
    required this.optimalValue,
    required this.analyseFaceValue,
  });

  Map<String, dynamic> toJson() => {
        'analyseFaceValue': analyseFaceValue.name,
        'optimalValue': optimalValue,
        'range': <String, dynamic>{
          'start': range.start,
          'end': range.end,
        },
      };
}

enum FaceMap {
  leftEyeOpenProbability,
  rightEyeOpenProbability,
  headEulerAngleX,
  headEulerAngleY,
  headEulerAngleZ;

  static double? getValue(FaceMap faceMap, Face face) {
    switch (faceMap) {
      case FaceMap.leftEyeOpenProbability:
        return face.leftEyeOpenProbability;
      case FaceMap.rightEyeOpenProbability:
        return face.rightEyeOpenProbability;
      case FaceMap.headEulerAngleX:
        return face.headEulerAngleX;
      case FaceMap.headEulerAngleY:
        return face.headEulerAngleY;
      case FaceMap.headEulerAngleZ:
        return face.headEulerAngleZ;
    }
  }
}
