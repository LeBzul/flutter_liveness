import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as mlkit;
import 'package:image/image.dart' as img;
import 'package:liveness/helper/image_helper.dart';

import '../face_recognizer.dart';
import 'face_recognition.dart';

class FaceImage {
  final mlkit.Face face;
  final img.Image image;
  final img.Image originalImage;
  bool _recognitionFailed = false;
  FaceRecognition? _faceRecognition;
  final FaceRecognizer _faceRecognizer;

  FaceImage({
    required this.face,
    required this.image,
    required this.originalImage,
    required FaceRecognizer faceRecognizer,
  }) : _faceRecognizer = faceRecognizer;

  Future<FaceRecognition?> faceRecognition() async {
    if (_recognitionFailed) {
      return null;
    }
    // Send cropped face to TensorFlow for recognizing and add name
    _faceRecognition = _faceRecognizer.recognize(
      this,
    );

    if (_faceRecognition == null) {
      _recognitionFailed = true;
      return null;
    }

    return _faceRecognition;
  }

  static Future<img.Image> generateFaceImageWithImage(
    mlkit.Face face,
    img.Image baseImage,
  ) async {
    // Convert CameraImage to Image and rotate it so that our frame will be in a portrait
    img.Image image = img.copyRotate(
      baseImage,
      angle: 0,
    );

    Rect faceRect = face.boundingBox;
    // Crop image to only have the head/face
    img.Image copyCrop = img.copyCrop(
      image,
      x: faceRect.left.toInt(),
      y: faceRect.top.toInt(),
      width: faceRect.width.toInt(),
      height: faceRect.height.toInt(),
    );

    return copyCrop;
  }

  static Future<img.Image?> generateFaceImageWithCameraImage(
    mlkit.Face face,
    CameraImage frame,
    CameraDescription cameraDescription,
  ) async {
    img.Image? baseImage = await ImageHelper.convertImage(frame); // Black and white conversion
    if (baseImage == null) {
      return null;
    }
    // Convert CameraImage to Image and rotate it so that our frame will be in a portrait
    img.Image image = img.copyRotate(
      baseImage,
      angle: Platform.isAndroid ? (cameraDescription.lensDirection == CameraLensDirection.front ? 270 : 90) : 0,
    );

    Rect faceRect = face.boundingBox;
    // Crop image to only have the head/face
    img.Image copyCrop = img.copyCrop(
      image,
      x: faceRect.left.toInt(),
      y: faceRect.top.toInt(),
      width: faceRect.width.toInt(),
      height: faceRect.height.toInt(),
    );

    return copyCrop;
  }
}
