import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:liveness/controllers/face_controller.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';
import 'package:liveness/models/liveness/condition/liveness_condition_result.dart';
import 'package:liveness/models/liveness/liveness_process.dart';
import 'package:liveness/models/report_analyze.dart';

class ReportScreen extends StatefulWidget {
  final LivenessProcess liveness;
  final FaceRecognition? faceRecognition;
  const ReportScreen({
    required this.liveness,
    required this.faceRecognition,
    Key? key,
  }) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = widget.liveness.livenessConditionResults().length + 2;
    itemCount += widget.faceRecognition?.faceImage != null ? 1 : 0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (_, i) {
          if (itemCount - 1 == i) {
            return SelectableText(
              ReportAnalyze.generateReportString(
                widget.liveness,
                widget.faceRecognition,
              ),
              style: const TextStyle(
                fontSize: 11.0,
                color: Colors.white,
              ),
            );
          }
          if (0 == i) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
                top: 20,
              ),
              child: Center(
                child: MaterialButton(
                  color: Colors.green,
                  onPressed: () async {
                    backToHome();
                  },
                  child: Text(
                    "Terminé avec succès (${widget.faceRecognition?.distance.toStringAsFixed(2)}/${FaceController.maxRecognitionDistance.toStringAsFixed(2)})",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }

          List<img.Image> listOfImages = [];
          String name = '';
          int indexLiveness = i - 1;
          if (widget.liveness.livenessConditionResults().length > indexLiveness) {
            for (LivenessConditionResult conditionResult
                in widget.liveness.livenessConditionResults()[indexLiveness].toList()) {
              listOfImages.add(conditionResult.faceImage.image);
            }
            name = widget.liveness.livenessConditionResults()[indexLiveness].first.name;
          } else if (widget.faceRecognition != null) {
            listOfImages.add(widget.faceRecognition!.faceImage.image);
            name = 'CNI';
          }

          return _buildList(
            context,
            name,
            listOfImages,
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    String name,
    List<img.Image> images,
  ) {
    return SizedBox(
      height: 120,
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return SizedBox(
                  child: Image.memory(
                    Uint8List.fromList(
                      img.encodeBmp(
                        images[index],
                      ),
                    ),
                  ),
                );
              },
              itemCount: images.length,
            ),
          ),
        ],
      ),
    );
  }

  void backToHome() {
    Navigator.popUntil(
      context,
      (Route<dynamic> predicate) => predicate.isFirst,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
