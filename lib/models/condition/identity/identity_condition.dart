import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/helper/image_helper.dart';
import 'package:liveness/models/condition/recognition_condition.dart';
import 'package:liveness/models/condition/recognition_condition_result.dart';
import 'package:liveness/models/face_recognizer/face_recognizer.dart';
import 'package:liveness/models/face_recognizer/model/face.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';

class IdentityCondition extends RecognitionCondition {
  List<String> imagesBase64;
  double? distance;

  FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      //enableTracking: true,
      enableClassification: true,
      minFaceSize: 0.5,
    ),
  );

  IdentityCondition({
    required super.name,
    required super.instruction,
    required this.imagesBase64,
  });

  @override
  void initConditionResult() {
    int i = 0;
    conditionResult = <int, RecognitionConditionResult?>{};
    for (var _ in imagesBase64) {
      conditionResult.putIfAbsent(i++, () => null);
    }
  }

  Future<void> checkIdentity(
    FaceRecognizer faceRecognizer,
  ) async {
    int indexRangesConditions = 0;
    for (var image in imagesBase64) {
      FaceImage? faceImage = await detectFaceWithImage(
        image,
        faceRecognizer,
      );
      if (faceImage == null) {
        indexRangesConditions++;
        continue;
      }
      FaceRecognition? faceRecognition = await faceImage.faceRecognition();
      if (faceRecognition == null) {
        indexRangesConditions++;
        continue;
      }
      distance = faceRecognition.distance;

      if (faceRecognition.distance > FaceController.maxRecognitionDistance) {
        indexRangesConditions++;
        continue;
      }

      conditionResult[indexRangesConditions] = RecognitionConditionResult(
        name: name,
        value: [faceRecognition.distance],
        faceImage: faceImage,
      );
      indexRangesConditions++;
    }
  }

  Future<FaceImage?> detectFaceWithImage(
    String base64,
    FaceRecognizer faceRecognizer,
  ) async {
    //Convert Image from MlKit Image
    InputImage? inputImage = await ImageHelper.getInputImageFromBase64(base64);
    img.Image? baseImage = ImageHelper.base64ToImage(base64);

    if (inputImage == null || baseImage == null) {
      return null;
    }

    List<Face> faces = await ImageHelper.detectFaceFromInputImage(
      inputImage,
      faceDetector,
    );

    img.Image? image = await FaceImage.generateFaceImageWithImage(
      faces.first,
      baseImage,
    );

    return FaceImage(
      face: faces.first,
      image: image,
      faceRecognizer: faceRecognizer,
    );
  }
}
