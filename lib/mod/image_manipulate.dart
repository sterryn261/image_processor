import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:dartcv4/dartcv.dart' as cv;

class ImageManipulate {
  Future<Uint8List> grayscaleImage({required Uint8List input}) async {
    final image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    final gray = await cv.cvtColorAsync(image, cv.COLOR_BGR2GRAY);

    final encode = (await cv.imencodeAsync(".png", gray)).$2;
    return encode;
  }

  Future<Uint8List> singleBGRChannel({
    required Uint8List input,
    required String channel,
  }) async {
    final image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    int first = 0;
    int second = 0;

    if (channel == 'R') {
      first = 0;
      second = 1;
    } else if (channel == 'G') {
      first = 0;
      second = 2;
    } else if (channel == 'B') {
      first = 1;
      second = 2;
    } else {
      final encode = (await cv.imencodeAsync(".png", image)).$2;
      return encode;
    }

    image.forEachPixel((row, col, pixel) {
      pixel[first] = 0;
      pixel[second] = 0;
    });

    final encode = (await cv.imencodeAsync(".png", image)).$2;
    return encode;
  }

  Future<Uint8List> edgeDetection({required Uint8List input}) async {
    final image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    final canny = cv.canny(image, image.height / 1.0, image.width / 1.0);

    final encode = (await cv.imencodeAsync(".png", canny)).$2;
    return encode;
  }

  ///0 (false) for Clockwise, 1 (true) for CounterClockwise
  Future<Uint8List> rotate({
    required Uint8List input,
    required bool direction,
  }) async {
    final image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    cv.Mat rotateImage = image;
    if (direction) {
      rotateImage = cv.rotate(image, cv.ROTATE_90_COUNTERCLOCKWISE);
    } else {
      rotateImage = cv.rotate(image, cv.ROTATE_90_CLOCKWISE);
    }

    final encode = (await cv.imencodeAsync(".png", rotateImage)).$2;
    return encode;
  }

  Future<Uint8List> flip({required Uint8List input}) async {
    final image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    final flipImage = cv.flip(image, 1);

    final encode = (await cv.imencodeAsync(".png", flipImage)).$2;
    return encode;
  }

  Future<Uint8List> colorCorrection({
    required Uint8List input,
    required double brightness,
    required double warmth,
    required double tint,
    required double alpha,
    required double beta,
  }) async {
    final image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    final contrast = await cv.convertScaleAbsAsync(
      image,
      alpha: alpha,
      beta: beta,
    );
    final lab = await cv.cvtColorAsync(contrast, cv.COLOR_BGR2Lab);
    lab.forEachPixel((row, col, pixel) {
      final brightnessInt = brightness.round();
      final warmthInt = warmth.round();
      final tintInt = tint.round();

      if (pixel[0] + brightnessInt < 0) {
        pixel[0] = 0;
      } else if (pixel[0] + brightnessInt > 255) {
        pixel[0] = 255;
      } else {
        pixel[0] += brightnessInt;
      }

      if (pixel[1] + warmthInt < 0) {
        pixel[1] = 0;
      } else if (pixel[1] + warmthInt > 255) {
        pixel[1] = 255;
      } else {
        pixel[1] += warmthInt;
      }

      if (pixel[2] + warmthInt < 0) {
        pixel[2] = 0;
      } else if (pixel[2] + warmthInt > 255) {
        pixel[2] = 255;
      } else {
        pixel[2] += warmthInt;
      }

      if (pixel[1] + tintInt < 0) {
        pixel[1] = 0;
      } else if (pixel[2] + tintInt > 255) {
        pixel[1] = 255;
      } else {
        pixel[1] += tintInt;
      }

      if (pixel[2] + tintInt < 0) {
        pixel[2] = 0;
      } else if (pixel[2] + tintInt > 255) {
        pixel[2] = 255;
      } else {
        pixel[2] -= tintInt;
      }
    });

    final output = await cv.cvtColorAsync(lab, cv.COLOR_Lab2BGR);

    final encode = (await cv.imencodeAsync(".png", output)).$2;
    return encode;
  }
}
