import 'package:json_annotation/json_annotation.dart';
import 'package:liveness/models/face.dart';

@JsonSerializable()
class LivenessConditionResult {
  String name;
  List<double> value;
  FaceImage faceImage;

  LivenessConditionResult({
    required this.name,
    required this.value,
    required this.faceImage,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value.map((e) => e.toStringAsFixed(2)).toList(),
      };
}