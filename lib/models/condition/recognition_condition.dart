import 'recognition_condition_result.dart';

abstract class RecognitionCondition {
  String instruction;
  String name;

  Map<int, RecognitionConditionResult?> conditionResult = <int, RecognitionConditionResult?>{};

  RecognitionCondition({
    required this.name,
    required this.instruction,
  }) {
    initConditionResult();
  }

  bool get isValidated => !conditionResult.containsValue(null);

  void initConditionResult() {
    conditionResult = <int, RecognitionConditionResult?>{};
  }

  void reset() {
    initConditionResult();
  }
}
