import 'liveness_condition_result.dart';

abstract class Condition {
  String instruction;
  String name;

  Map<int, LivenessConditionResult?> conditionResult = <int, LivenessConditionResult?>{};

  Condition({
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
