import 'dart:io';

import 'package:flutter/material.dart';
import 'package:liveness/models/liveness/condition/liveness_condition.dart';

enum LivenessFaceDirectionTurn {
  left,
  right,
}

/// Sur android la gauche et la droite est inversé ( en mode selfie )
mixin LivenessFaceTurn {
  static List<List<LivenessRangeCondition>> directionConditions(
    LivenessFaceDirectionTurn direction,
  ) {
    return [
      [
        LivenessRangeCondition(
          range: RangeCondition(
            value: direction == LivenessFaceDirectionTurn.left
                ? (Platform.isAndroid ? const RangeValues(5, 15) : const RangeValues(-15, -5))
                : (Platform.isAndroid ? const RangeValues(-15, -5) : const RangeValues(5, 15)),
            optimalValue: direction == LivenessFaceDirectionTurn.left
                ? (Platform.isAndroid ? 15 : -15)
                : (Platform.isAndroid ? -15 : 15),
          ),
          analyseFaceValue: FaceMap.faceAngleY,
        ),
      ],
      [
        LivenessRangeCondition(
          range: RangeCondition(
            value: direction == LivenessFaceDirectionTurn.left
                ? (Platform.isAndroid ? const RangeValues(16, 30) : const RangeValues(-30, -16))
                : (Platform.isAndroid ? const RangeValues(-30, -16) : const RangeValues(16, 30)),
            optimalValue: direction == LivenessFaceDirectionTurn.left
                ? (Platform.isAndroid ? 30 : -30)
                : (Platform.isAndroid ? -30 : 30),
          ),
          analyseFaceValue: FaceMap.faceAngleY,
        ),
      ],
    ];
  }
}
