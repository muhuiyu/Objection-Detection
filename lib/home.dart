import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'package:object_detection/camera.dart';
import 'package:object_detection/bindbox.dart';

const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage(this.cameras, {super.key});

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    super.initState();
  }

  _loadModel() async {
    String? res;
    res = await Tflite.loadModel(
        // model: "assets/tfLite/efficientdet_lite0.tflite",
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt");

    if (res != null) {
      log(res);
    }
  }

  _onSelect(model) {
    setState(() {
      _model = model;
    });
    _loadModel();
  }

  _setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _model = "";
              });
            }),
        title: Text("Object detection"),
      ),
      backgroundColor: Colors.white,
      body: _model == ""
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    padding: const EdgeInsets.all(20),
                    color: Colors.blueAccent,
                    child: const Text(
                      ssd,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _onSelect(ssd),
                  ),
                  MaterialButton(
                    color: Colors.blueAccent,
                    child: const Text(
                      yolo,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _onSelect(yolo),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Camera(
                  widget.cameras,
                  _model,
                  _setRecognitions,
                ),
                BindBox(
                  _recognitions ?? [],
                  math.max(_imageHeight, _imageWidth),
                  math.min(_imageHeight, _imageWidth),
                  screen.height,
                  screen.width,
                ),
              ],
            ),
    );
  }
}
