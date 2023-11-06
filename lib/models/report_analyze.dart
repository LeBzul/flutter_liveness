import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:liveness/controllers/face_controller.dart';

import 'face_recognizer/model/face_recognition.dart';
import 'liveness/liveness_process.dart';

class ReportAnalyze {
  static Map<String, dynamic> generateReport({
    required LivenessProcess liveness,
    required FaceRecognition? cniRecognition,
  }) {
    Map<String, dynamic> reportMap = <String, dynamic>{};
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

    reportMap.putIfAbsent(
      'model',
      () => FaceController.selectedFaceNet.value,
    );
    LivenessProcess? livenessTemp = liveness;
    reportMap.putIfAbsent(
      'liveness',
      () => livenessTemp?.toJson(),
    );

    reportMap.putIfAbsent(
      'livenessStep',
      () => livenessTemp.actualStep ?? "end",
    );
    FaceRecognition? cniRecognitionTemp = cniRecognition;
    reportMap.putIfAbsent(
      'cni',
      () => cniRecognitionTemp?.toJson(),
    );
    return reportMap;
  }

  static String generateReportString(
    LivenessProcess liveness,
    FaceRecognition? cniRecognition,
  ) {
    return jsonEncode(generateReport(
      liveness: liveness,
      cniRecognition: cniRecognition,
    ));
  }
}
