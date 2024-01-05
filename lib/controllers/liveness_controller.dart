import 'package:camera/camera.dart';
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/models/face_recognizer/model/face.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';
import 'package:liveness/models/liveness/condition/liveness_condition.dart';
import 'package:liveness/models/liveness/condition/liveness_condition_result.dart';
import 'package:liveness/models/liveness/liveness_process.dart';

class LivenessController extends FaceController {
  LivenessProcess liveNess;

  List<LivenessCondition> liveNessStepConditions;
  List<LivenessCondition> liveNessPassiveStepConditions;

  final Function(
    LivenessController controller,
    List<FaceRecognition> faceRecognitions,
  ) livenessSuccessResult;

  final Function(
    LivenessController controller,
    LivenessCondition? actualCondition,
    int stepCount,
    int maxStep,
  )? stepConditionChange;

  final Function(
    LivenessController controller,
    List<LivenessCondition> errorConditions,
  ) livenessErrorResult;

  final bool showInstructions;
  final bool showPictureFrame;

  LivenessController({
    required this.liveNessStepConditions,
    required this.liveNessPassiveStepConditions,
    required this.livenessSuccessResult,
    required this.livenessErrorResult,
    required Function() cameraError,
    this.showInstructions = true,
    this.showPictureFrame = true,
    this.stepConditionChange,
  })  : liveNess = LivenessProcess(
          liveNessActiveConditions: liveNessStepConditions,
          liveNessPassiveConditions: liveNessPassiveStepConditions,
        ),
        super(
          cameraError: cameraError,
          registeredFaces: [],
        );

  @override
  void refreshCamera() async {
    super.refreshCamera();
    stepConditionChange?.call(
      this,
      liveNess.actualStep,
      liveNess.stepCount,
      liveNess.maxStep,
    );
  }

  @override
  Future<FaceImage?> detectFaceCameraImage(
    CameraImage frame,
    CameraDescription description,
  ) async {
    if (liveNess.livenessIsCompleted) {
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
      stepConditionChange?.call(
        this,
        liveNess.actualStep,
        liveNess.stepCount,
        liveNess.maxStep,
      );
    }

    if (liveNess.livenessIsCompleted) {
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

        livenessSuccessResult.call(
          this,
          await _getAllFaceRecognition(),
        );
      } else {
        livenessErrorResult.call(
          this,
          compareErrorsList,
        );
      }
    }
    state = ControllerState.refresh;
    return faceImage;
  }

  Future<List<LivenessCondition>> _checkAll() async {
    if (!liveNess.livenessIsCompleted) {
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

        if (faceRecognition.distance > maxRecognitionDistance) {
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
      } else if (faceRecognition.distance > maxRecognitionDistance) {
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

  void reset() {
    faceRecognizer.registered.clear();
    liveNess.reset();
    stepConditionChange?.call(
      this,
      liveNess.actualStep,
      liveNess.stepCount,
      liveNess.maxStep,
    );
  }
}
