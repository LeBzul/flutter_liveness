import 'package:liveness/models/condition/liveness/liveness_condition.dart';

class LivenessCustomCondition extends LivenessCondition {
  LivenessCustomCondition({
    required String instruction,
    required List<List<LivenessRangeCondition>> rangesConditionsList,
  }) : super(
          rangesConditionsList: rangesConditionsList,
          instruction: instruction,
        );
}
