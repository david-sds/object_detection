import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Video extends StatefulWidget {
  const Video({
    this.model,
    super.key,
  });

  final ModelObjectDetection? model;

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  CameraController? _controller;
  bool _isStreaming = false;
  File? currentFrame;
  List<ResultObjectDetection?> frameDetection = [];

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> loadCamera() async {
    try {
      print('searching aval cams!');
      final avalCams = await availableCameras();
      print('cams found => ${avalCams.length}');
      if (avalCams.isNotEmpty) {
        final cam = avalCams.first;
        print('cam found');
        final camCtrl = CameraController(
          cam,
          ResolutionPreset.high,
          enableAudio: false,
          fps: 1,
        );
        print('ctrl created');
        await camCtrl.initialize();
        print('cam initialized');
        setState(() {
          _controller = camCtrl;
        });
      }
    } catch (e) {
      if (e is CameraException) {
        print('camera exception!');
        print(e.code);
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      } else {
        print('not camera exception!');
      }
      // print(e);
    }
  }

  void _startStreaming() {
    if (_controller != null && !_isStreaming) {
      _isStreaming = true;
      _controller?.startImageStream((CameraImage image) async {
        // Convert the CameraImage to a format suitable for streaming
        await _processCameraImage(image);
      });
    }
  }

  void _stopStreaming() {
    if (_isStreaming) {
      _controller!.stopImageStream();
      _isStreaming = false;
    }
  }

  Future<Uint8List?> _convertYUV420ToImage(CameraImage image) async {
    final int width = image.width;
    final int height = image.height;

    final img.Image convertedImage = img.Image(width: width, height: height);
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;

    if (uvPixelStride == null) {
      return null;
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;

        final int yIndex = y * image.planes[0].bytesPerRow + x;
        final int yValue = image.planes[0].bytes[yIndex];

        final int uValue = image.planes[1].bytes[uvIndex];
        final int vValue = image.planes[2].bytes[uvIndex];

        final int rValue = (yValue + (1.370705 * (vValue - 128))).toInt();
        final int gValue =
            (yValue - (0.337633 * (uValue - 128)) - (0.698001 * (vValue - 128)))
                .toInt();
        final int bValue = (yValue + (1.732446 * (uValue - 128))).toInt();

        convertedImage.setPixelRgba(x, y, rValue, gValue, bValue, 255);
      }
    }

    return Uint8List.fromList(img.encodeJpg(convertedImage));
  }

  Future<File?> _saveUint8ListToFile(Uint8List bytes) async {
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

  Future<void> _processCameraImage(CameraImage image) async {
    final convertedImg = await _convertYUV420ToImage(image);
    if (convertedImg == null) {
      print('Fail to convert CameraImage to byte array');
      return;
    }
    final imgAsFile = await _saveUint8ListToFile(convertedImg);
    if (imgAsFile == null) {
      print('Fail to convert byte arra to file');
      return;
    }
    final objDetectRes = await widget.model?.getImagePrediction(
          convertedImg,
          minimumScore: 0.1,
          IOUThershold: 0.3,
        ) ??
        [];
    setState(() {
      currentFrame = imgAsFile;
      frameDetection = objDetectRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final camCtrl = _controller;
    final cFrame = currentFrame;
    final frameWidget = cFrame != null
        ? widget.model?.renderBoxesOnImage(
            cFrame,
            frameDetection,
          )
        : const SizedBox();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            color: Colors.amber,
            child: camCtrl == null
                ? const Text('Play to detect object.')
                : CameraPreview(camCtrl),
          ),
        ),
        Column(
          children: [
            Container(
              color: Colors.purple,
              child: camCtrl == null
                  ? const Text('Play to detect object.')
                  : SizedBox(
                      width: 240,
                      height: 240,
                      child: frameWidget,
                    ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _startStreaming,
                  child: const Icon(Icons.play_arrow),
                ),
                ElevatedButton(
                  onPressed: _stopStreaming,
                  child: const Icon(Icons.stop_circle),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
