import 'liveness_condition_result.dart';

abstract class RecognitionCondition {
  String instruction;
  String name;

  Map<int, LivenessConditionResult?> conditionResult = <int, LivenessConditionResult?>{};

  RecognitionCondition({
    required this.name,
    required this.instruction,
  }) {
    initConditionResult();
  }

  bool get isValidated => !conditionResult.containsValue(null);

  void initConditionResult() {
    conditionResult = <int, LivenessConditionResult?>{};
  }

  void reset() {
    initConditionResult();
  }
}
