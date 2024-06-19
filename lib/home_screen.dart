import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:object_detection/camera.dart';
import 'package:object_detection/video/video.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ModelObjectDetection? _objectModel;
  @override
  void initState() {
    loadModel();
    super.initState();
  }

  Future<void> loadModel() async {
    String pathObjectDetectionModel = "assets/models/yolov5s.torchscript";
    try {
      final result = await FlutterPytorch.loadObjectDetectionModel(
        pathObjectDetectionModel,
        labelPath: "assets/labels/labels.txt",
        80,
        640,
        640,
      );
      setState(() {
        _objectModel = result;
      });
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("OBJECT DETECTOR APP"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.camera)),
              Tab(icon: Icon(Icons.video_call)),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: TabBarView(
          children: [
            Camera(model: _objectModel),
            Video(model: _objectModel),
          ],
        ),
      ),
    );
  }
}
