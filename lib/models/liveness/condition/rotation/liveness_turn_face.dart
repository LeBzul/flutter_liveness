import 'dart:io';

import 'package:flutter/material.dart';
import 'package:liveness/models/liveness/condition/liveness_condition.dart';

enum LiveNessTurnFaceDirection {
  left,
  right,
}

/// Sur android la gauche et la droite est inversé
mixin LiveNessTurnFace {
  static List<List<LivenessRangeCondition>> directionConditions(
    LiveNessTurnFaceDirection direction,
  ) {
    return [
      [
        LivenessRangeCondition(
          range: direction == LiveNessTurnFaceDirection.left
              ? (Platform.isAndroid ? const RangeValues(10, 20) : const RangeValues(-20, -10))
              : (Platform.isAndroid ? const RangeValues(-20, -10) : const RangeValues(10, 20)),
          optimalValue: direction == LiveNessTurnFaceDirection.left
              ? (Platform.isAndroid ? 20 : -20)
              : (Platform.isAndroid ? -20 : 20),
          analyseFaceValue: FaceMap.headEulerAngleY,
        )
      ],
      [
        LivenessRangeCondition(
          range: direction == LiveNessTurnFaceDirection.left
              ? (Platform.isAndroid ? const RangeValues(20, 30) : const RangeValues(-30, -20))
              : (Platform.isAndroid ? const RangeValues(-40, -20) : const RangeValues(20, 30)),
          optimalValue: direction == LiveNessTurnFaceDirection.left
              ? (Platform.isAndroid ? 30 : -30)
              : (Platform.isAndroid ? -30 : 30),
          analyseFaceValue: FaceMap.headEulerAngleY,
        )
      ],
      [
        LivenessRangeCondition(
          range: direction == LiveNessTurnFaceDirection.left
              ? (Platform.isAndroid ? const RangeValues(35, 80) : const RangeValues(-80, -35))
              : (Platform.isAndroid ? const RangeValues(-80, -35) : const RangeValues(40, 80)),
          optimalValue: direction == LiveNessTurnFaceDirection.left
              ? (Platform.isAndroid ? 50 : -50)
              : (Platform.isAndroid ? -50 : 50),
          analyseFaceValue: FaceMap.headEulerAngleY,
        )
      ],
    ];
  }
}
