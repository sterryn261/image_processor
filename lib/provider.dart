import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './mod/image_manipulate.dart' as im;

class ImportedImage extends ChangeNotifier {
  Uint8List? _originalNoFilter;
  Uint8List? _originalImage;
  Uint8List? _currentImage;
  Uint8List? _grayscaleImage;
  Uint8List? _redImage;
  Uint8List? _blueImage;
  Uint8List? _greenImage;
  Uint8List? _canny;

  Uint8List? get originalNoFilter => _originalNoFilter;
  Uint8List? get originalImage => _originalImage;
  Uint8List? get currentImage => _currentImage;
  Uint8List? get grayscaleImage => _grayscaleImage;
  Uint8List? get redImage => _redImage;
  Uint8List? get blueImage => _blueImage;
  Uint8List? get greenImage => _greenImage;
  Uint8List? get canny => _canny;

  double _brightness = 0;

  double get brightness => _brightness;
  set brightness(double value) {
    _brightness = value;

    update();
    notifyListeners();
  }

  double _warmth = 0;

  double get warmth => _warmth;
  set warmth(double value) {
    _warmth = value;

    update();
    notifyListeners();
  }

  double _tint = 0;

  double get tint => _tint;
  set tint(double value) {
    _tint = value;

    update();
    notifyListeners();
  }

  final _pick = ImagePicker();

  Future<void> openPicker() async {
    final XFile? picked = await _pick.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      throw Exception("Invalid image path");
    }
    _originalNoFilter = await picked.readAsBytes();

    await update();
    notifyListeners();
  }

  Future<void> rotateImage(bool direction) async {
    _originalNoFilter = await im.ImageManipulate().rotate(
      input: _originalNoFilter!,
      direction: direction,
    );

    await update();
    notifyListeners();
  }

  Future<void> flipImage(bool direction) async {
    _originalNoFilter = await im.ImageManipulate().flip(
      input: _originalNoFilter!,
    );

    await update();
    notifyListeners();
  }

  Future<void> update() async {
    _originalImage = _originalNoFilter;
    _originalImage = await im.ImageManipulate().colorCorrection(
      input: _originalImage!,
      brightness: _brightness,
      warmth: _warmth,
      tint: _tint,
    );
    _currentImage = _originalImage;
    _grayscaleImage = await im.ImageManipulate().grayscaleImage(
      input: _currentImage!,
    );
    _redImage = await im.ImageManipulate().singleBGRChannel(
      input: _currentImage!,
      channel: "R",
    );
    _blueImage = await im.ImageManipulate().singleBGRChannel(
      input: _currentImage!,
      channel: "B",
    );
    _greenImage = await im.ImageManipulate().singleBGRChannel(
      input: _currentImage!,
      channel: "G",
    );
    _canny = await im.ImageManipulate().edgeDetection(input: _currentImage!);
  }
}
