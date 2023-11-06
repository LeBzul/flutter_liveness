import 'dart:math';

import 'package:flutter/services.dart';
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/models/face.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'model/face_recognition.dart';

class FaceRecognizer {
  FaceNet modelName;
  final NormalizeOp _preProcessNormalizeOp = NormalizeOp(127.5, 127.5);
  final NormalizeOp _postProcessNormalizeOp = NormalizeOp(0, 1);

  Interpreter? _interpreter;
  InterpreterOptions? _interpreterOptions;

  List<FaceRecognition> registered = [];

  List<int> _inputShape = [];
  List<int> _outputShape = [];

  TensorBuffer? _outputBuffer;

  TfLiteType _inputType = TfLiteType.float32;
  SequentialProcessor<TensorBuffer>? _probabilityProcessor;

  FaceRecognizer({
    required this.modelName,
    required this.registered,
    int? numThreads,
  }) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions?.threads = numThreads;
    }
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      final ByteData data = await rootBundle.load('packages/liveness/assets/${modelName.value}');
      final Uint8List bytes = data.buffer.asUint8List();

      Interpreter interpreter = Interpreter.fromBuffer(
        bytes,
        options: _interpreterOptions,
      );

      _interpreter = interpreter;
      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;

      _inputType = interpreter.getInputTensor(0).type;
      TfLiteType outputType = interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, outputType);
      _probabilityProcessor = TensorProcessorBuilder()
          .add(
            _postProcessNormalizeOp,
          )
          .build();
    } catch (e) {
      print(e.toString());
    }
  }

  FaceRecognition? recognize(FaceImage faceImage) {
    TensorBuffer? outputBuffer = _outputBuffer;
    SequentialProcessor<TensorBuffer>? probabilityProcessor = _probabilityProcessor;
    if (outputBuffer == null || probabilityProcessor == null) {
      return null;
    }

    TensorImage inputImage = TensorImage(_inputType);
    inputImage.loadImage(
      faceImage.image,
    );
    inputImage = _preProcess(inputImage);
    _interpreter?.run(
      inputImage.buffer,
      outputBuffer.getBuffer(),
    );
    probabilityProcessor.process(outputBuffer);

    _PairNameDistance pair = _findNearest(
      outputBuffer.getDoubleList(),
    );
    return FaceRecognition(
      faceImage,
      outputBuffer.getDoubleList(),
      pair.distance,
    );
  }

  TensorImage _preProcess(TensorImage inputImage) {
    int cropSize = min(inputImage.height, inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
          _inputShape[1],
          _inputShape[2],
          ResizeMethod.NEAREST_NEIGHBOUR,
        ))
        .add(_preProcessNormalizeOp)
        .build()
        .process(inputImage);
  }

  // Return nearest pair <name, distance> in dataset
  _PairNameDistance _findNearest(List<double> emb) {
    _PairNameDistance pair = _PairNameDistance(null, 5);
    int index = 0;
    for (var item in registered) {
      final String name = '$index';
      List<double> knownEmb = item.embeddings;
      double distance = 0;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - knownEmb[i];
        distance += diff * diff;
      }
      if (pair.distance == 5 || distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
      }
      index++;
    }

    return pair;
  }

  void close() {
    _interpreter?.close();
  }
}

class _PairNameDistance {
  String? name;
  double distance;
  _PairNameDistance(
    this.name,
    this.distance,
  );
}
