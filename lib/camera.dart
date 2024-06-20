import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:image_picker/image_picker.dart';

class Camera extends StatefulWidget {
  const Camera({
    this.model,
    super.key,
  });
  final ModelObjectDetection? model;
  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  String? _imagePrediction;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];
  Duration? duration;

  @override
  void initState() {
    super.initState();
  }

  Future<void> runObjectDetection() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) {
      return;
    }
    final start = DateTime.now();
    final objDetectRes = await widget.model?.getImagePrediction(
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
    final end = DateTime.now();
    setState(() {
      _image = File(image.path);
      objDetect = objDetectRes ?? [];
      duration = end.difference(start);
    });
  }

  @override
  Widget build(BuildContext context) {
    final img = _image;
    return Center(
      child: Stack(
        children: [
          Column(
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
                                  : widget.model?.renderBoxesOnImage(
                                      img,
                                      objDetect,
                                    )
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
              ElevatedButton(
                onPressed: () {
                  runObjectDetection();
                },
                child: const Icon(Icons.camera),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                color: Colors.black.withOpacity(.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (duration != null)
                      Text(
                        'Elapsed time: ${duration?.inMilliseconds}ms',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ...List.generate(objDetect.length, (index) {
                      final obj = objDetect[index];
                      return Text(
                        '${obj?.classIndex} ${obj?.className} (${obj?.score.toStringAsFixed(3)})',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
