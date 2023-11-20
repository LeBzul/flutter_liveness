import 'package:camera/camera.dart';
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/models/face.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';
import 'package:liveness/models/liveness/condition/liveness_condition.dart';
import 'package:liveness/models/liveness/condition/liveness_condition_result.dart';

import '../models/liveness/liveness_process.dart';

class LivenessController extends FaceController {
  LivenessProcess liveNess = LivenessProcess(
    liveNessActiveConditions: [],
    liveNessPassiveConditions: [],
  );

  List<LivenessCondition> liveNessStepConditions;
  List<LivenessCondition> liveNessPassiveStepConditions;
  final Function(
    LivenessProcess liveness,
    List<FaceRecognition> faceRecognitions,
    double distance,
  ) livenessSuccessResult;

  final Function(LivenessCondition? actualLivenessCondition)?
      actualLivenessChange;
  final Function(List<LivenessCondition> errorConditions) livenessErrorResult;
  String identityImageBase64;

  LivenessController({
    required super.stateChangeListener,
    required this.liveNessStepConditions,
    required this.liveNessPassiveStepConditions,
    required this.livenessSuccessResult,
    required this.livenessErrorResult,
    required this.identityImageBase64,
    this.actualLivenessChange,
  }) : super(
          cameraError: () {
            livenessErrorResult([]);
          },
          registeredFaces: [],
        ) {
    liveNess.liveNessActiveConditions = liveNessStepConditions;
    liveNess.liveNessPassiveConditions = liveNessPassiveStepConditions;
  }

  @override
  void refreshCamera() async {
    super.refreshCamera();
    actualLivenessChange?.call(liveNess.actualStep);
  }

  @override
  Future<FaceImage?> detectFaceCameraImage(
    CameraImage frame,
    CameraDescription description,
  ) async {
    if (liveNess.isCompleted) {
      return null;
    }
    FaceImage? faceImage =
        await super.detectFaceCameraImage(frame, description);
    if (faceImage == null) {
      return null;
    }

    LivenessCondition? lastCondition = liveNess.actualStep;
    liveNess.updateFaceLiveNess(
      faceImage,
    );
    if (lastCondition != liveNess.actualStep) {
      actualLivenessChange?.call(liveNess.actualStep);
    }

    if (liveNess.isCompleted) {
      List<LivenessCondition> compareErrorsList = await _checkAll();
      if (compareErrorsList.isEmpty) {
        _identityVerificationLiveness();
      } else {
        livenessErrorResult.call(compareErrorsList);
      }
    }
    state = ControllerState.refresh;
    return faceImage;
  }

  void _identityVerificationLiveness() async {
    FaceImage? faceImage = await detectFaceWithImage(identityImageBase64);
    if (faceImage == null) {
      return;
    }

    FaceRecognition? faceRecognition = await faceImage.faceRecognition();
    if (faceRecognition == null) {
      return;
    }
    if (faceRecognition.distance > FaceController.maxRecognitionDistance) {
      return null;
    }

    livenessSuccessResult.call(
      liveNess,
      await _getAllFaceRecognition(),
      faceRecognition.distance,
    );
  }

  Future<List<LivenessCondition>> _checkAll() async {
    if (!liveNess.isCompleted) {
      return liveNess.allLivenessCondition();
    }

    List<LivenessCondition> conditionResultErrors = [];

    /// 1) On compare toutes les images d'une meme condition
    for (LivenessCondition livenessCondition
        in liveNess.allLivenessCondition()) {
      // On compare toutes les conditions de la liste
      faceRecognizer.registered.clear();
      for (var value in livenessCondition.conditionResult.values) {
        LivenessConditionResult? liveNessConditionResult = value;
        if (liveNessConditionResult == null) {
          conditionResultErrors.add(livenessCondition);
          continue;
        }
        FaceRecognition? faceRecognition =
            await liveNessConditionResult.faceImage.faceRecognition();
        if (faceRecognition == null) {
          conditionResultErrors.add(livenessCondition);
          continue;
        }
        if (value == livenessCondition.conditionResult.values.first) {
          faceRecognizer.registered.add(faceRecognition);
          continue;
        }

        if (faceRecognition.distance > FaceController.maxRecognitionDistance) {
          conditionResultErrors.add(livenessCondition);
          continue;
        }
      }
    }

    /// 2) On compare la 1ere images de chaques conditions
    faceRecognizer.registered.clear();
    for (LivenessCondition livenessCondition
        in liveNess.allLivenessCondition()) {
      if (livenessCondition.conditionResult.isEmpty) {
        conditionResultErrors.add(livenessCondition);
        continue;
      }
      FaceRecognition? faceRecognition = await livenessCondition
          .conditionResult.values.first?.faceImage
          .faceRecognition();
      if (faceRecognition == null) {
        conditionResultErrors.add(livenessCondition);
        continue;
      }
      if (livenessCondition == liveNess.allLivenessCondition().first) {
        faceRecognizer.registered.add(faceRecognition);
      } else if (faceRecognition.distance >
          FaceController.maxRecognitionDistance) {
        /// Comme on ne peut pas determiner lequel est réelement en erreurs, on les mets tous en erreurs
        return liveNess.allLivenessCondition();
      }
    }
    faceRecognizer.registered.clear();
    return conditionResultErrors;
  }

  Future<List<FaceRecognition>> _getAllFaceRecognition() async {
    List<FaceRecognition> faceRecognitionList = [];
    for (LivenessCondition livenessCondition
        in liveNess.allLivenessCondition()) {
      for (var element in livenessCondition.conditionResult.values) {
        if (element == null) {
          continue;
        }
        FaceImage? faceImage = element.faceImage;
        FaceRecognition? faceRecognition = await faceImage.faceRecognition();
        if (faceRecognition == null) {
          continue;
        }
        faceRecognitionList.add(faceRecognition);
      }
    }
    return faceRecognitionList;
  }
}
