import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/controllers/recognizing_controller.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';

class RecognizingWidget extends StatefulWidget {
  final List<FaceRecognition> faceRecognitions;

  final Function() errorResult;

  final Function(
    FaceRecognition recognition,
  ) successResult;
  final bool removeBlurredResult;

  const RecognizingWidget({
    Key? key,
    required this.faceRecognitions,
    required this.successResult,
    required this.errorResult,
    this.removeBlurredResult = true,
  }) : super(key: key);

  @override
  State<RecognizingWidget> createState() => _RecognizingWidgetState();
}

class _RecognizingWidgetState extends State<RecognizingWidget> {
  late RecognizingController _controller;

  @override
  void initState() {
    super.initState();
    List<FaceRecognition> registeredFaces = [];
    for (var faceRecognition in widget.faceRecognitions) {
      registeredFaces.add(faceRecognition);
    }

    _controller = RecognizingController(
      cameraError: () {
        widget.errorResult.call();
      },
      successResult: (FaceRecognition recognition) {
        widget.successResult.call(recognition);
      },
      registeredFaces: registeredFaces,
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
        buildCameraWidgetHeader(),
      ],
    );
  }

  Widget buildCameraWidgetHeader() {
    return Positioned(
      top: 0.0,
      left: 0.0,
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white.withAlpha(100),
        height: 100,
        child: const Center(
          child: Text("Scan de la CNI"),
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
