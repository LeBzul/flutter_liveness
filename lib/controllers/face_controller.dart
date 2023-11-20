import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:liveness/models/face.dart';
import 'package:liveness/models/face_recognizer/face_recognizer.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';

import '../helper/image_helper.dart';

enum FaceNet {
  facenet(value: 'facenet.tflite'),
  mobileFaceNet(value: 'mobile_face_net.tflite');

  final String value;
  const FaceNet({required this.value});
}

enum ControllerState {
  loading,
  refresh,
}

class FaceController {
  static FaceNet selectedFaceNet = FaceNet.facenet;
  static double maxRecognitionDistance = 0.65;
  bool cameraBusy = false;

  Function(ControllerState state) stateChangeListener;

  final Function() cameraError;
  ControllerState _state = ControllerState.loading;
  set state(ControllerState value) {
    _state = value;
    stateChangeListener.call(_state);
  }

  ControllerState get state => _state;

  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  CameraDescription? cameraDescription;

  //Face detection on a CameraImage
  FaceRecognition? lastFaceRecognition;

  // MlKit FaceDetector
  FaceDetector? faceDetector;
  //Face recognizer
  late FaceRecognizer faceRecognizer;

  FaceController({
    required this.stateChangeListener,
    required this.cameraError,
    required List<FaceRecognition> registeredFaces,
    CameraLensDirection cameraLensDirection = CameraLensDirection.front,
  }) {
    //Initialize mlkit face detector
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        //enableTracking: true,
        enableClassification: true,
        minFaceSize: 0.5,
      ),
    );

    faceRecognizer = FaceRecognizer(
      modelName: selectedFaceNet,
      registered: registeredFaces,
    );

    firstInitializeCamera(
      direction: cameraLensDirection,
    );
  }

  Future<void> firstInitializeCamera({
    CameraLensDirection direction = CameraLensDirection.front,
  }) async {
    state = ControllerState.loading;
    cameras = await availableCameras();
    if (cameras.isEmpty) {
      cameraError.call();
      return;
    }

    CameraDescription description = cameras.first;
    for (CameraDescription cameraDescription in cameras) {
      if (cameraDescription.lensDirection == direction) {
        description = cameraDescription;
      }
    }
    cameraDescription = description;
    refreshCamera();
  }

  // Initialize Camera
  void refreshCamera() async {
    CameraDescription? cameraDescription = this.cameraDescription;
    if (cameraDescription == null) {
      return;
    }

    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController?.initialize().then((_) async {
      cameraController?.startImageStream(
        (image) async => {
          if (!cameraBusy)
            {
              _performDetectFace(
                image,
                cameraDescription,
              ),
            },
          state = ControllerState.refresh,
        },
      );
    });

    cameraController?.lockCaptureOrientation(DeviceOrientation.portraitUp);
    state = ControllerState.refresh;
  }

  Future<void> _performDetectFace(
    CameraImage frame,
    CameraDescription description,
  ) async {
    cameraBusy = true;
    await detectFaceCameraImage(
      frame,
      description,
    );
    cameraBusy = false;
  }

  Future<FaceImage?> detectFaceCameraImage(
    CameraImage frame,
    CameraDescription description,
  ) async {
    //Convert CameraImage from MlKit Image
    InputImage? inputImage = ImageHelper.getInputImageFromCamera(
      frame,
      description,
    );

    if (inputImage == null) {
      return null;
    }

    List<Face> faces = await detectFaceFromInputImage(inputImage);

    img.Image? image = await FaceImage.generateFaceImageWithCameraImage(
      faces.first,
      frame,
      description,
    );
    if (image == null) {
      return null;
    }

    return FaceImage(
      face: faces.first,
      image: image,
      faceRecognizer: faceRecognizer,
    );
  }

  Future<FaceImage?> detectFaceWithImage(String base64) async {
    //Convert CameraImage from MlKit Image
    InputImage? inputImage = ImageHelper.getInputImageFromBase64(base64);
    img.Image? baseImage = ImageHelper.base64ToImage(base64);

    if (inputImage == null || baseImage == null) {
      return null;
    }

    List<Face> faces = await detectFaceFromInputImage(inputImage);

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

  Future<List<Face>> detectFaceFromInputImage(InputImage inputImage) async {
    FaceDetector? detector = faceDetector;
    List<Face> faces = [];
    if (detector == null) {
      return faces;
    }

    //Face detector return List of all faces detected in CameraImage
    faces = await detector.processImage(
      inputImage,
    );

    return faces;
  }

  void dispose() {
    try {
      cameraController?.stopImageStream();
    } on CameraException catch (_, e) {
      // Le streaming est déjà lancé
    }
    cameraController?.dispose();
  }
}
