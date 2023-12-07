import 'package:liveness/helper/list_helper.dart';
import 'package:liveness/liveness.dart';
import 'package:liveness/models/face_recognizer/model/face.dart';

import 'liveness_condition.dart';

class LivenessProcess {
  int? faceId;

  List<LivenessCondition> liveNessActiveConditions;
  List<LivenessCondition> liveNessPassiveConditions;
  IdentityCondition identityCondition;
  LivenessProcess({
    required this.liveNessActiveConditions,
    required this.liveNessPassiveConditions,
    required this.identityCondition,
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

  RecognitionCondition? get actualStep {
    LivenessCondition? step = liveNessActiveConditions.firstWhereOrNull(
      (element) => element.conditionResult.containsValue(null),
    );

    if (step != null) {
      return step;
    }

    step = liveNessPassiveConditions.firstWhereOrNull(
      (element) => element.conditionResult.containsValue(null),
    );
    if (step != null) {
      return step;
    }

    return identityCondition;
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

  void reset({List<RecognitionConditionResult>? conditionReset}) {
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
    List<RecognitionConditionResult>? conditionsReset,
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
    RecognitionCondition? actualStep = this.actualStep;
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

  List<List<RecognitionConditionResult>> livenessConditionResults() {
    List<List<RecognitionConditionResult>> conditionsList = [];
    for (var element in liveNessActiveConditions) {
      List<RecognitionConditionResult> tempList = [];
      List<RecognitionConditionResult?> results = element.conditionResult.values.toList();
      for (var result in results) {
        if (result != null) {
          tempList.add(result);
        }
      }
      conditionsList.add(tempList);
    }

    for (var element in liveNessPassiveConditions) {
      List<RecognitionConditionResult> tempList = [];
      List<RecognitionConditionResult?> results = element.conditionResult.values.toList();
      for (var result in results) {
        if (result != null) {
          tempList.add(result);
        }
      }
      conditionsList.add(tempList);
    }
    return conditionsList;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> liveNessActiveConditionsMap = <String, dynamic>{};
    for (var element in liveNessActiveConditions) {
      liveNessActiveConditionsMap.putIfAbsent(element.name, () => element.toJson());
    }

    Map<String, dynamic> liveNessPassiveConditionsMap = <String, dynamic>{};
    for (var element in liveNessPassiveConditions) {
      liveNessPassiveConditionsMap.putIfAbsent(element.name, () => element.toJson());
    }

    return <String, dynamic>{
      "liveNessActiveConditions": liveNessActiveConditionsMap,
      "liveNessPassiveConditions": liveNessPassiveConditionsMap,
    };
  }
}
