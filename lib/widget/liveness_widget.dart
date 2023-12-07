import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/controllers/liveness_controller.dart';
import 'package:liveness/models/condition/identity/identity_condition.dart';
import 'package:liveness/models/condition/liveness/liveness_condition.dart';
import 'package:liveness/models/condition/liveness/liveness_process.dart';
import 'package:liveness/models/condition/recognition_condition.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';

class LivenessWidget extends StatefulWidget {
  final List<LivenessCondition> liveNessActiveConditions;
  final List<LivenessCondition> liveNessPassiveConditions;
  final IdentityCondition identityCondition;
  final Function(
    LivenessProcess liveness,
    List<FaceRecognition> faceRecognitions,
    IdentityCondition identityCondition,
  ) livenessSuccessResult;
  final Function(
    RecognitionCondition? actualCondition,
    int stepCount,
    int maxStep,
  )? stepConditionChange;
  final Function(
    LivenessProcess liveness,
    List<RecognitionCondition> errorConditions,
  ) livenessErrorResult;

  final bool showInstructions;
  final bool showPictureFrame;

  const LivenessWidget({
    Key? key,
    required this.liveNessActiveConditions,
    required this.liveNessPassiveConditions,
    required this.livenessSuccessResult,
    required this.livenessErrorResult,
    required this.identityCondition,
    this.stepConditionChange,
    this.showInstructions = true,
    this.showPictureFrame = true,
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
      livenessSuccessResult: (liveness, faceRecognitions, identityCondition) {
        widget.livenessSuccessResult.call(
          liveness,
          faceRecognitions,
          identityCondition,
        );
        setState(() {});
      },
      livenessErrorResult: (errorConditions) {
        widget.livenessErrorResult.call(
          _controller.liveNess,
          errorConditions,
        );
        setState(() {});
      },
      stepConditionChange: widget.stepConditionChange,
      identityCondition: widget.identityCondition,
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
        widget.showPictureFrame
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return CustomPaint(
                    painter: _LivenessPictureFramePainter(
                      Size(
                        constraints.maxWidth,
                        constraints.maxHeight - (widget.showInstructions ? 100 : 0),
                      ),
                    ),
                  );
                },
              )
            : Container(),
        widget.showInstructions ? buildOverlay() : Container(),
      ],
    );
  }

  Widget buildOverlay() {
    return Positioned(
      top: 0.0,
      left: 0.0,
      width: MediaQuery.of(context).size.width,
      child: Container(
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

class _LivenessPictureFramePainter extends CustomPainter {
  Size size;

  _LivenessPictureFramePainter(
    this.size,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Calcul du centre du conteneur
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    canvas.saveLayer(Rect.largest, Paint());

    // In your paint method
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withAlpha(70),
          Colors.white,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            centerX,
            centerY,
          ),
          radius: size.height / 2,
        ),
      );

    const double widthToHeightRatio = 0.6;
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        this.size.width,
        this.size.height,
      ),
      paint,
    );

    const double paddingRatio = 0.1;

    // Calcul du rayon en fonction de la largeur de l'écran et du ratio
    double radiusX = (size.width - 2 * size.width * paddingRatio) / 2;
    double radiusY = radiusX / widthToHeightRatio;

    // Vérification pour éviter que l'ovale ne dépasse de l'écran
    if (radiusY > size.height / 2) {
      radiusY = size.height / 2;
      radiusX = radiusY * widthToHeightRatio;
    }

    // Dessine l'oval avec drawOval
    Rect ovalRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: radiusX * 2,
      height: radiusY * 2,
    );
    canvas.drawOval(
      ovalRect,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
