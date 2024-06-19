// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VideoController on _VideoControllerBase, Store {
  Computed<CameraImage?>? _$imageComputed;

  @override
  CameraImage? get image =>
      (_$imageComputed ??= Computed<CameraImage?>(() => super.image,
              name: '_VideoControllerBase.image'))
          .value;
  Computed<Uint8List?>? _$convertedImageComputed;

  @override
  Uint8List? get convertedImage => (_$convertedImageComputed ??=
          Computed<Uint8List?>(() => super.convertedImage,
              name: '_VideoControllerBase.convertedImage'))
      .value;

  late final _$_imageAtom =
      Atom(name: '_VideoControllerBase._image', context: context);

  @override
  CameraImage? get _image {
    _$_imageAtom.reportRead();
    return super._image;
  }

  @override
  set _image(CameraImage? value) {
    _$_imageAtom.reportWrite(value, super._image, () {
      super._image = value;
    });
  }

  late final _$_VideoControllerBaseActionController =
      ActionController(name: '_VideoControllerBase', context: context);

  @override
  void setImage(CameraImage? value) {
    final _$actionInfo = _$_VideoControllerBaseActionController.startAction(
        name: '_VideoControllerBase.setImage');
    try {
      return super.setImage(value);
    } finally {
      _$_VideoControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Uint8List? _convertYUV420ToImage(CameraImage? image) {
    final _$actionInfo = _$_VideoControllerBaseActionController.startAction(
        name: '_VideoControllerBase._convertYUV420ToImage');
    try {
      return super._convertYUV420ToImage(image);
    } finally {
      _$_VideoControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
image: ${image},
convertedImage: ${convertedImage}
    ''';
  }
}
