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

  Future<img.Image> generateCropFaceWithRatio() async {
    Rect faceRect = _addPaddingFaceRect(face.boundingBox, originalImage);

    // Crop image en ratio 3/4
    return _copyCropRatio(
      originalImage,
      faceRect.left.toInt(),
      faceRect.top.toInt(),
      faceRect.width.toInt(),
      faceRect.height.toInt(),
      3 / 4,
    );
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

    return img.copyCrop(
      image,
      x: face.boundingBox.left.toInt(),
      y: face.boundingBox.top.toInt(),
      width: face.boundingBox.width.toInt(),
      height: face.boundingBox.height.toInt(),
    );
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

    return img.copyCrop(
      image,
      x: face.boundingBox.left.toInt(),
      y: face.boundingBox.top.toInt(),
      width: face.boundingBox.width.toInt(),
      height: face.boundingBox.height.toInt(),
    );
  }

  static Rect _addPaddingFaceRect(
    Rect faceRect,
    img.Image image,
  ) {
    double paddingWidth = (faceRect.width * 10) / 100;
    double paddingHeight = (faceRect.height * 40) / 100;
    int x = (faceRect.left - paddingWidth / 2).toInt();
    if (x < 0) {
      x = 0;
    }
    int y = (faceRect.top - paddingHeight * 2 / 3).toInt();
    if (y < 0) {
      x = 0;
    }
    int width = (faceRect.width + paddingWidth).toInt();
    int height = (faceRect.height + paddingHeight).toInt();
    if (x + width > image.width) {
      width = image.width - x;
    }
    if (y + height > image.height) {
      height = image.height - y;
    }

    return Rect.fromLTWH(
      x.toDouble(),
      y.toDouble(),
      width.toDouble(),
      height.toDouble(),
    );
  }

  static int _findClosestIntegerMultiple(double n, double ratio, bool addHeight) {
    int closestIntegerMultiple = n.round(); // Initialisation avec la valeur arrondie de n

    while ((closestIntegerMultiple * ratio) % 1 != 0) {
      addHeight ? closestIntegerMultiple++ : closestIntegerMultiple--; // Incrémente jusqu'à trouver un multiple entier
    }

    return closestIntegerMultiple;
  }

  static Future<img.Image> _copyCropRatio(
    img.Image image,
    int x,
    int y,
    int originalWidth,
    int height,
    double targetRatio,
  ) async {
    // Définissez la nouvelle largeur et hauteur souhaitée
    double targetWidth = 200.0;
    double targetHeight = (targetWidth / image.width) * image.height;

    // Redimensionnez l'image sans changer son ratio
    img.Image resizedImage = img.copyResize(image, width: targetWidth.toInt(), height: targetHeight.toInt());
    return resizedImage;
    /*
    String base64String = base64Encode(
      img.encodePng(
        resizedImage,
      ),
    );
    Map<String, String> base64Image = {
      'base64': base64String,
      'extension': 'png',
    };
    print(base64String);



// Calculer la largeur de l'image en fonction du ratio
    height = _findClosestIntegerMultiple(
      height.toDouble(),
      targetRatio,
      true,
    );
    double targetWidth = height * targetRatio;
    double targetX = x - ((targetWidth - originalWidth) / 2);
    if (targetX < 0) {
      height = _findClosestIntegerMultiple(
        height.toDouble(),
        targetRatio,
        false,
      );
      targetWidth = height * targetRatio;
      targetX = x - ((targetWidth - originalWidth) / 2);
    }

    img.Image copyCropped = img.copyCrop(
      image,
      x: targetX.toInt(),
      y: y,
      width: targetWidth.toInt(),
      height: height,
    );

    if (copyCropped.width != targetWidth.toInt()) {
      print("OOPS");
    }

    if (copyCropped.height * 0.75 != copyCropped.width) {
      print("OOPS");
    }

    if (copyCropped.height != height.toInt()) {
      print("OOPS");
    }
    if (x < 0) {
      print("OOPS");
    }
    if (y < 0) {
      print("OOPS");
    }

    return copyCropped;
// Crop image en utilisant les nouvelles dimensions et position
    return await resizeImage(
        img.copyCrop(
          image,
          x: targetX.toInt(),
          y: y,
          width: targetWidth.toInt(),
          height: height,
        ),
        300);*/
  }

// TODO: A TESTER SUR IOS
  static Future<img.Image> resizeImage(img.Image originalImage, int targetHeight) async {
    // Calculez la nouvelle taille en conservant le ratio
    double aspectRatio = originalImage.width / originalImage.height;

    int newWidth, newHeight;

    newHeight = targetHeight;
    newWidth = (targetHeight * aspectRatio).round();

    // Redimensionnez l'image en conservant le ratio
    return img.copyResize(originalImage, width: newWidth, height: newHeight);
  }
}
