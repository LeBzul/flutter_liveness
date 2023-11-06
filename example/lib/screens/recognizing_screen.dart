import 'package:example/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:liveness/models/face_recognizer/model/face_recognition.dart';
import 'package:liveness/models/liveness/liveness_process.dart';
import 'package:liveness/widget/recognizing_widget.dart';

class RecognizingScreen extends StatefulWidget {
  final LivenessProcess liveness;

  final List<FaceRecognition> faceRecognitions;
  const RecognizingScreen({
    Key? key,
    required this.liveness,
    required this.faceRecognitions,
  }) : super(key: key);

  @override
  State<RecognizingScreen> createState() => _RecognizingScreenState();
}

class _RecognizingScreenState extends State<RecognizingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: RecognizingWidget(
            successResult: (recognition) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportScreen(
                    liveness: widget.liveness,
                    faceRecognition: recognition,
                  ),
                ),
              );
            },
            errorResult: () {},
            faceRecognitions: widget.faceRecognitions,
          ),
        ),
      ),
    );
  }
}
