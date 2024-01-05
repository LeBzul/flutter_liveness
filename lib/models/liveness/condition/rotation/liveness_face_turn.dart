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
                ? (Platform.isAndroid ? const RangeValues(5, 30) : const RangeValues(-30, 5))
                : (Platform.isAndroid ? const RangeValues(-30, -5) : const RangeValues(5, 30)),
            optimalValue: direction == LivenessFaceDirectionTurn.left
                ? (Platform.isAndroid ? 20 : -20)
                : (Platform.isAndroid ? -20 : 20),
          ),
          analyseFaceValue: FaceMap.faceAngleY,
        ),
      ],
      [
        LivenessRangeCondition(
          range: RangeCondition(
            value: direction == LivenessFaceDirectionTurn.left
                ? (Platform.isAndroid ? const RangeValues(25, 60) : const RangeValues(-60, -25))
                : (Platform.isAndroid ? const RangeValues(-60, -25) : const RangeValues(25, 60)),
            optimalValue: direction == LivenessFaceDirectionTurn.left
                ? (Platform.isAndroid ? 40 : -40)
                : (Platform.isAndroid ? -40 : 40),
          ),
          analyseFaceValue: FaceMap.faceAngleY,
        ),
      ],
    ];
  }
}
