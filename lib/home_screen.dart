import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ModelObjectDetection? _objectModel;
  String? _imagePrediction;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];

  @override
  void initState() {
    super.initState();
    loadModel();
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

  Future<void> runObjectDetection() async {
    //pick an image

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) {
      return;
    }
    final objDetectRes = await _objectModel?.getImagePrediction(
      await File(image.path).readAsBytes(),
      minimumScore: 0.1,
      IOUThershold: 0.3,
    );

    for (var element in objDetect) {
      print({
        "score": element?.score,
        "className": element?.className,
        "class": element?.classIndex,
        "rect": {
          "left": element?.rect.left,
          "top": element?.rect.top,
          "width": element?.rect.width,
          "height": element?.rect.height,
          "right": element?.rect.right,
          "bottom": element?.rect.bottom,
        },
      });
    }
    print('setting image!');
    setState(() {
      _image = File(image.path);
      objDetect = objDetectRes ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    print('rendering again!');
    final img = _image;
    return Scaffold(
      appBar: AppBar(title: const Text("OBJECT DETECTOR APP")),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          color: Colors.amber,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.blue,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 640,
                          width: 640,
                          child: objDetect.isNotEmpty
                              ? img == null
                                  ? const Text('No image selected 1.')
                                  : _objectModel?.renderBoxesOnImage(
                                      img, objDetect)
                              : img == null
                                  ? const Text('No image selected 2.')
                                  : Image.file(img),
                        ),
                        Center(
                          child: Text(_imagePrediction ?? 'Nothing found'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Column(
              //   children: [
              //     SizedBox(
              //       height: 400,
              //       width: 400,
              //       child: objDetect.isNotEmpty
              //           ? img == null
              //               ? const Text('No image selected 1.')
              //               : _objectModel?.renderBoxesOnImage(img, objDetect)
              //           : img == null
              //               ? const Text('No image selected 2.')
              //               : Image.file(img),
              //     ),
              //     Center(
              //       child: Visibility(
              //         visible: _imagePrediction != null,
              //         child: Text("$_imagePrediction"),
              //       ),
              //     ),
              //   ],
              // ),
              // //Button to click pic
              ElevatedButton(
                onPressed: () {
                  runObjectDetection();
                },
                child: const Icon(Icons.camera),
              )
            ],
          ),
        ),
      ),
    );
  }
}
