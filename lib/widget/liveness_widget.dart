import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/controllers/liveness_controller.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';
import 'package:liveness/models/liveness/condition/liveness_condition.dart';
import 'package:liveness/models/liveness/liveness_process.dart';

class LivenessWidget extends StatefulWidget {
  final List<LivenessCondition> liveNessActiveConditions;
  final List<LivenessCondition> liveNessPassiveConditions;
  final Function(LivenessProcess liveness, List<FaceRecognition> faceRecognitions) livenessSuccessResult;
  final Function(LivenessCondition? actualLivenessCondition)? actualLivenessChange;
  final Function(
    LivenessProcess liveness,
    List<LivenessCondition> errorConditions,
  ) livenessErrorResult;

  final Widget? instructionsOverlay;
  final bool removeBlurredResult;

  const LivenessWidget({
    Key? key,
    required this.liveNessActiveConditions,
    required this.liveNessPassiveConditions,
    required this.livenessSuccessResult,
    required this.livenessErrorResult,
    this.actualLivenessChange,
    this.instructionsOverlay,
    this.removeBlurredResult = true,
  }) : super(key: key);

  @override
  State<LivenessWidget> createState() => _LivenessWidgetState();
}

class _LivenessWidgetState extends State<LivenessWidget> {
  late LivenessController _controller;

  @override
  void initState() {
    super.initState();

    _controller = LivenessController(
      stateChangeListener: (ControllerState state) {
        if (!mounted) {
          return;
        }

        setState(() {});
      },
      liveNessStepConditions: widget.liveNessActiveConditions,
      liveNessPassiveStepConditions: widget.liveNessPassiveConditions,
      livenessSuccessResult: (liveness, faceRecognitions) {
        widget.livenessSuccessResult.call(liveness, faceRecognitions);
        setState(() {});
      },
      livenessErrorResult: (errorConditions) {
        widget.livenessErrorResult.call(
          _controller.liveNess,
          errorConditions,
        );
        setState(() {});
      },
      actualLivenessChange: widget.actualLivenessChange,
      removeBlurredResult: widget.removeBlurredResult,
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    switch (_controller.state) {
      case ControllerState.loading:
        return buildLoading();
      case ControllerState.refresh:
        return buildCameraWidget();
    }
  }

  Widget buildError() {
    return Container(
      color: Colors.red,
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildCameraWidget() {
    CameraController? controller = _controller.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return buildLoading();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
        buildOverlay(),
      ],
    );
  }

  Widget buildOverlay() {
    return Positioned(
      top: 0.0,
      left: 0.0,
      width: MediaQuery.of(context).size.width,
      child: widget.instructionsOverlay ??
          Container(
            color: Colors.white.withAlpha(100),
            height: 100,
            child: Center(
              child: Text(_controller.liveNess.actualStep?.instruction ?? ""),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
