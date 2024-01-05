import 'package:liveness/helper/list_helper.dart';
import 'package:liveness/models/face_recognizer/model/face.dart';
import 'package:liveness/models/liveness/condition/liveness_condition_result.dart';

import 'condition/liveness_condition.dart';

class LivenessProcess {
  int? faceId;

  List<LivenessCondition> liveNessActiveConditions;
  List<LivenessCondition> liveNessPassiveConditions;
  LivenessProcess({
    required this.liveNessActiveConditions,
    required this.liveNessPassiveConditions,
  });

  bool get livenessIsCompleted {
    for (var condition in liveNessActiveConditions) {
      if (condition.isValidated == false) {
        return false;
      }
    }
    for (var condition in liveNessPassiveConditions) {
      if (condition.isValidated == false) {
        return false;
      }
    }
    return true;
  }

  LivenessCondition? get actualStep {
    LivenessCondition? step = liveNessActiveConditions.firstWhereOrNull(
      (element) => element.conditionResult.containsValue(null),
    );

    if (step != null) {
      return step;
    }

    step = liveNessPassiveConditions.firstWhereOrNull(
      (element) => element.conditionResult.containsValue(null),
    );
    return step;
  }

  int get maxStep {
    // Add one for indentification step
    return liveNessActiveConditions.length + liveNessPassiveConditions.length + 1;
  }

  int get stepCount {
    LivenessCondition? step = liveNessActiveConditions.firstWhereOrNull(
      (element) => element.conditionResult.containsValue(null),
    );

    if (step != null) {
      return liveNessActiveConditions.indexOf(step);
    }

    step = liveNessPassiveConditions.firstWhereOrNull(
      (element) => element.conditionResult.containsValue(null),
    );

    if (step != null) {
      return liveNessActiveConditions.length + liveNessPassiveConditions.indexOf(step);
    }

    return maxStep;
  }

  void reset({List<LivenessConditionResult>? conditionReset}) {
    _resetCondition(
      conditions: liveNessActiveConditions,
      conditionsReset: conditionReset,
    );
    _resetCondition(
      conditions: liveNessPassiveConditions,
      conditionsReset: conditionReset,
    );
  }

  void _resetCondition({
    required List<LivenessCondition> conditions,
    List<LivenessConditionResult>? conditionsReset,
  }) {
    for (var condition in conditions) {
      if (conditionsReset == null) {
        condition.reset();
      } else {
        for (var element in conditionsReset) {
          if (condition.conditionResult.containsValue(element)) {
            condition.reset();
          }
        }
      }
    }
  }

  void updateFaceLiveNess(
    FaceImage faceImage,
  ) {
    LivenessCondition? actualStep = this.actualStep;
    if (actualStep is LivenessCondition) {
      actualStep.updateFace(faceImage);
      for (var element in liveNessPassiveConditions) {
        element.updateFace(faceImage);
      }
    }
  }

  List<LivenessCondition> allLivenessCondition() {
    List<LivenessCondition> conditionsList = [];
    for (var element in liveNessActiveConditions) {
      conditionsList.add(element);
    }
    for (var element in liveNessPassiveConditions) {
      conditionsList.add(element);
    }
    return conditionsList;
  }

  List<List<LivenessConditionResult>> livenessConditionResults() {
    List<List<LivenessConditionResult>> conditionsList = [];
    for (var element in liveNessActiveConditions) {
      List<LivenessConditionResult> tempList = [];
      List<LivenessConditionResult?> results = element.conditionResult.values.toList();
      for (var result in results) {
        if (result != null) {
          tempList.add(result);
        }
      }
      conditionsList.add(tempList);
    }

    for (var element in liveNessPassiveConditions) {
      List<LivenessConditionResult> tempList = [];
      List<LivenessConditionResult?> results = element.conditionResult.values.toList();
      for (var result in results) {
        if (result != null) {
          tempList.add(result);
        }
      }
      conditionsList.add(tempList);
    }
    return conditionsList;
  }
}
