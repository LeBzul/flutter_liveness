import 'package:camera/camera.dart';
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/models/face.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';
import 'package:liveness/models/liveness/condition/condition.dart';
import 'package:liveness/models/liveness/condition/identity_condition.dart';
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
    IdentityCondition identityCondition,
  ) livenessSuccessResult;

  final Function(
    Condition? actualCondition,
  )? stepConditionChange;

  final Function(
    List<Condition> errorConditions,
  ) livenessErrorResult;

  final IdentityCondition identityCondition;

  LivenessController({
    required super.stateChangeListener,
    required this.liveNessStepConditions,
    required this.liveNessPassiveStepConditions,
    required this.livenessSuccessResult,
    required this.livenessErrorResult,
    required this.identityCondition,
    this.stepConditionChange,
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
    stepConditionChange?.call(liveNess.actualStep);
  }

  @override
  Future<FaceImage?> detectFaceCameraImage(
    CameraImage frame,
    CameraDescription description,
  ) async {
    if (liveNess.isCompleted) {
      return null;
    }
    FaceImage? faceImage = await super.detectFaceCameraImage(frame, description);
    if (faceImage == null) {
      return null;
    }

    LivenessCondition? lastCondition = liveNess.actualStep;
    liveNess.updateFaceLiveNess(
      faceImage,
    );
    if (lastCondition != liveNess.actualStep) {
      stepConditionChange?.call(liveNess.actualStep);
    }

    if (liveNess.isCompleted) {
      List<LivenessCondition> compareErrorsList = await _checkAll();
      if (compareErrorsList.isEmpty) {
        faceRecognizer.registered.clear();
        for (var condition in liveNessStepConditions) {
          for (var entry in condition.conditionResult.entries) {
            FaceRecognition? faceRecognition = await entry.value?.faceImage.faceRecognition();
            if (faceRecognition != null) {
              faceRecognizer.registered.add(faceRecognition);
            }
          }
        }

        await identityCondition.checkIdentity(faceRecognizer);

        if (identityCondition.isValidated) {
          livenessSuccessResult.call(
            liveNess,
            await _getAllFaceRecognition(),
            identityCondition,
          );
        } else {
          livenessErrorResult.call([identityCondition]);
        }
      } else {
        livenessErrorResult.call(compareErrorsList);
      }
    }
    state = ControllerState.refresh;
    return faceImage;
  }

  Future<List<LivenessCondition>> _checkAll() async {
    if (!liveNess.isCompleted) {
      return liveNess.allLivenessCondition();
    }

    List<LivenessCondition> conditionResultErrors = [];

    /// 1) On compare toutes les images d'une meme condition
    for (LivenessCondition livenessCondition in liveNess.allLivenessCondition()) {
      // On compare toutes les conditions de la liste
      faceRecognizer.registered.clear();
      for (var value in livenessCondition.conditionResult.values) {
        LivenessConditionResult? liveNessConditionResult = value;
        if (liveNessConditionResult == null) {
          conditionResultErrors.add(livenessCondition);
          continue;
        }
        FaceRecognition? faceRecognition = await liveNessConditionResult.faceImage.faceRecognition();
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
    for (LivenessCondition livenessCondition in liveNess.allLivenessCondition()) {
      if (livenessCondition.conditionResult.isEmpty) {
        conditionResultErrors.add(livenessCondition);
        continue;
      }
      FaceRecognition? faceRecognition =
          await livenessCondition.conditionResult.values.first?.faceImage.faceRecognition();
      if (faceRecognition == null) {
        conditionResultErrors.add(livenessCondition);
        continue;
      }
      if (livenessCondition == liveNess.allLivenessCondition().first) {
        faceRecognizer.registered.add(faceRecognition);
      } else if (faceRecognition.distance > FaceController.maxRecognitionDistance) {
        /// Comme on ne peut pas determiner lequel est réelement en erreurs, on les mets tous en erreurs
        return liveNess.allLivenessCondition();
      }
    }
    faceRecognizer.registered.clear();
    return conditionResultErrors;
  }

  Future<List<FaceRecognition>> _getAllFaceRecognition() async {
    List<FaceRecognition> faceRecognitionList = [];
    for (LivenessCondition livenessCondition in liveNess.allLivenessCondition()) {
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
