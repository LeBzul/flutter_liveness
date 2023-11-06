import 'package:camera/camera.dart';
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/models/face.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';

class RecognizingController extends FaceController {
  bool recognizingFinish = false;
  final Function(
    FaceRecognition recognition,
  ) successResult;

  RecognizingController({
    required super.stateChangeListener,
    required this.successResult,
    required super.cameraError,
    required List<FaceRecognition> registeredFaces,
    super.removeBlurredResult = true,
  }) : super(
          cameraLensDirection: CameraLensDirection.back,
          registeredFaces: registeredFaces,
        );

  @override
  Future<FaceImage?> detectFace(
    CameraImage frame,
    CameraDescription description,
  ) async {
    if (recognizingFinish) {
      return null;
    }
    FaceImage? faceImage = await super.detectFace(frame, description);
    if (faceImage == null) {
      return null;
    }

    FaceRecognition? recognition = await faceImage.faceRecognition();
    if (recognition == null) {
      return faceImage;
    }

    if (recognition.distance < FaceController.maxRecognitionDistance) {
      recognizingFinish = true;
      successResult.call(recognition);
    }

    return faceImage;
  }
}
