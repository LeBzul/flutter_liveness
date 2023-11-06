import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.absoluteImageSize,
    this.faceRecognition,
    this.camDirection,
  );

  final Size absoluteImageSize;
  final FaceRecognition? faceRecognition;
  CameraLensDirection camDirection;
  final Paint paintRectFace = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..color = Colors.lightGreen;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    FaceRecognition? faceRecognition = this.faceRecognition;
    if (faceRecognition != null) {
      _drawRectFace(
        canvas,
        faceRecognition,
        scaleX,
        scaleY,
      );
    }
  }

  void _drawRectFace(
    Canvas canvas,
    FaceRecognition faceRecognition,
    double scaleX,
    double scaleY,
  ) {
    Face face = faceRecognition.faceImage.face;

    canvas.drawRect(
      Rect.fromLTRB(
        camDirection == CameraLensDirection.front
            ? (absoluteImageSize.width - face.boundingBox.right) * scaleX
            : face.boundingBox.left * scaleX,
        face.boundingBox.top * scaleY,
        camDirection == CameraLensDirection.front
            ? (absoluteImageSize.width - face.boundingBox.left) * scaleX
            : face.boundingBox.right * scaleX,
        face.boundingBox.bottom * scaleY,
      ),
      paintRectFace,
    );
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}
