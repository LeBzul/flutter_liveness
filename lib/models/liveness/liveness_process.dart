import 'package:json_annotation/json_annotation.dart';
import 'package:liveness/helper/list_helper.dart';
import 'package:liveness/models/face.dart';
import 'package:liveness/models/liveness/condition/liveness_condition_result.dart';

import 'condition/liveness_condition.dart';

@JsonSerializable()
class LivenessProcess {
  int? faceId;

  List<LivenessCondition> liveNessActiveConditions;
  List<LivenessCondition> liveNessPassiveConditions;
  LivenessProcess({
    required this.liveNessActiveConditions,
    required this.liveNessPassiveConditions,
  });

  bool get isCompleted {
    for (var condition in liveNessActiveConditions) {
      if (condition.alive == false) {
        return false;
      }
    }
    for (var condition in liveNessPassiveConditions) {
      if (condition.alive == false) {
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

    return liveNessPassiveConditions.firstWhereOrNull(
      (element) => element.conditionResult.containsValue(null),
    );
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
    actualStep?.updateFace(faceImage);
    for (var element in liveNessPassiveConditions) {
      element.updateFace(faceImage);
    }
  }

/*
  void updateLiveNess(
    FaceRecognition recognition,
  ) {
    //Pas très fiable apparement
    if (faceId != recognition.faceImage.face.trackingId) {
      //  reset();
    }

    faceId = recognition.faceImage.face.trackingId;

    actualStep?.update(
      recognition.faceImage.face,
      recognition.faceImage.image,
      recognition,
    );

    for (var element in liveNessPassiveConditions) {
      element.update(
        recognition.faceImage.face,
        recognition.faceImage.image,
        recognition,
      );
    }
  }
*/

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
