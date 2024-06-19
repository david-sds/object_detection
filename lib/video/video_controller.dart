import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:mobx/mobx.dart';

part 'video_controller.g.dart';

class VideoController extends _VideoControllerBase with _$VideoController {}

abstract class _VideoControllerBase with Store {
  @observable
  CameraImage? _image;
  @computed
  CameraImage? get image => _image;
  @action
  void setImage(CameraImage? value) => _image = value;

  @computed
  Uint8List? get convertedImage => _convertYUV420ToImage(_image);

  @action
  Uint8List? _convertYUV420ToImage(CameraImage? image) {
    if (image == null) {
      return null;
    }

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
}
