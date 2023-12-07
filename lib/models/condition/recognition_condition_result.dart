import 'package:liveness/models/face_recognizer/model/face.dart';

class RecognitionConditionResult {
  String name;
  List<double> value;
  FaceImage faceImage;

  RecognitionConditionResult({
    required this.name,
    required this.value,
    required this.faceImage,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value.map((e) => e.toStringAsFixed(2)).toList(),
      };
}
