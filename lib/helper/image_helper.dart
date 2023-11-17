import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class ImageHelper {
  static Future<img.Image?> convertImage(CameraImage image) async {
    try {
      img.Image? imageResult;
      if (image.format.group == ImageFormatGroup.yuv420) {
        /// CameraImage type yuv420 in Android
        imageResult = _convertYUV420(
          image,
        );
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        /// CameraImage type BGRA8888 in iOS
        imageResult = _convertBGRA8888(image);
      }

      return imageResult;
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:$e");
    }
    return null;
  }

  static img.Image _convertBGRA8888ToGray(img.Image src) {
    var p = src.getBytes();
    for (var i = 0, len = p.length; i < len; i += 4) {
      var l = img.getLuminanceRgb(p[i], p[i + 1], p[i + 2]);
      p[i] = l.toInt();
      p[i + 1] = l.toInt();
      p[i + 2] = l.toInt();
    }
    return src;
  }

// CameraImage BGRA8888 -> PNG
  static img.Image _convertBGRA8888(CameraImage image) {
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
    /*_convertBGRA8888ToGray(img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    ));*/
  }

  static img.Image _convertYUV420(CameraImage image) {
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 0;
    final convertImage = img.Image(width: image.width, height: image.height);
    for (final p in convertImage) {
      final x = p.x;
      final y = p.y;
      final uvIndex =
          uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
      final index = y * uvRowStride +
          x; // Use the row stride instead of the image width as some devices pad the image data, and in those cases the image width != bytesPerRow. Using width will give you a distored image.
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      p.r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255).toInt();
      p.g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255)
          .toInt();
      p.b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255).toInt();
    }
    return convertImage;
  }

  /// Convert CameraImage from MlKit Image
  static InputImage? getInputImage(
    CameraImage cameraImage,
    CameraDescription description,
  ) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );
    final camera = description;
    final imageRotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (imageRotation == null) {
      return null;
    }

    final inputImageFormat = InputImageFormatValue.fromRawValue(
      cameraImage.format.raw,
    );
    if (inputImageFormat == null) {
      return null;
    }

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return InputImageMetadata(
          bytesPerRow: plane.bytesPerRow,
          size: Size(
            plane.width?.toDouble() ?? 0,
            plane.height?.toDouble() ?? 0,
          ),
          rotation: imageRotation,
          format: inputImageFormat,
        );
      },
    ).toList();

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: planeData.first.bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageData,
    );

    return inputImage;
  }
}
