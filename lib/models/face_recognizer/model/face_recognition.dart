import 'package:liveness/models/face_recognizer/model/face.dart';

class FaceRecognition {
  FaceImage faceImage;
  //Rect location;
  List<double> embeddings;
  double distance;

  /// Constructs a Category.
  FaceRecognition(
    this.faceImage,
    //  this.location,
    this.embeddings,
    this.distance,
  );

  Map<String, dynamic> toJson() => {
        'distance': distance.toStringAsFixed(2),
      };
}
