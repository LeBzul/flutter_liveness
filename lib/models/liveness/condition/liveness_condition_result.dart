import 'package:liveness/models/face_recognizer/model/face.dart';

class LivenessConditionResult {
  List<double> value;
  FaceImage faceImage;

  LivenessConditionResult({
    required this.value,
    required this.faceImage,
  });

  Map<String, dynamic> toJson() => {
        'value': value.map((e) => e.toStringAsFixed(2)).toList(),
      };
}
