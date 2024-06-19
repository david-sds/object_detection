import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:object_detection/video/frame/frame.dart';
import 'package:object_detection/video/video_controller.dart';

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
  final ctrl = VideoController();
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

  Future<void> _processCameraImage(CameraImage image) async {
    ctrl.setImage(image);
  }

  @override
  Widget build(BuildContext context) {
    final camCtrl = _controller;
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
                  : Frame(
                      ctrl: ctrl,
                      model: widget.model,
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
