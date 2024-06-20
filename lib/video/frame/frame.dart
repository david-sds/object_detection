import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:mobx/mobx.dart';
import 'package:object_detection/video/video_controller.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Frame extends StatefulWidget {
  const Frame({
    required this.ctrl,
    this.model,
    super.key,
  });

  final VideoController ctrl;
  final ModelObjectDetection? model;

  @override
  State<Frame> createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  ReactionDisposer? disposer;
  File? currentFrame;
  List<ResultObjectDetection?> frameDetection = [];

  @override
  void initState() {
    disposer = reaction<Uint8List?>(
      (_) => widget.ctrl.convertedImage,
      (byteArray) async {
        final imageAsFile = await _saveUint8ListToFile(byteArray);

        if (byteArray == null) {
          return;
        }

        final objDetectRes = await widget.model?.getImagePrediction(
              byteArray,
              minimumScore: 0.1,
              IOUThershold: 0.3,
            ) ??
            [];

        setState(() {
          currentFrame = imageAsFile;
          frameDetection = objDetectRes;
        });
      },
    );
    super.initState();
  }

  Future<File?> _saveUint8ListToFile(Uint8List? bytes) async {
    if (bytes == null) {
      return null;
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(
          directory.path, 'image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('frame');
    final cFrame = currentFrame;
    final frameWidget = cFrame != null
        ? widget.model?.renderBoxesOnImage(
            cFrame,
            frameDetection,
          )
        : const SizedBox();
    return SizedBox(
      width: 240,
      height: 240,
      child: frameWidget,
    );
  }
}
