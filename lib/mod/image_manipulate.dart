import 'dart:math';
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

  Future<cv.Mat> linearTransform({
    required cv.Mat input,
    required double alpha,
    required double beta,
  }) async {
    final contrast = await cv.convertScaleAbsAsync(
      input,
      alpha: alpha,
      beta: beta,
    );
    return contrast;
  }

  Future<cv.Mat> labTransform({
    required cv.Mat input,
    required double brightness,
    required double warmth,
    required double tint,
  }) async {
    final lab = await cv.cvtColorAsync(input, cv.COLOR_BGR2Lab);
    lab.forEachPixel((row, col, pixel) {
      final brightnessInt = brightness.round();
      final warmthInt = warmth.round();
      final tintInt = tint.round();

      pixel[0] = (pixel[0] + brightnessInt < 0)
          ? 0
          : (pixel[0] + brightnessInt > 255)
          ? 255
          : (pixel[0] + brightnessInt);

      pixel[1] = (pixel[1] + warmthInt < 0)
          ? 0
          : (pixel[1] + warmthInt > 255)
          ? 255
          : (pixel[1] + warmthInt);

      pixel[2] = (pixel[2] + warmthInt < 0)
          ? 0
          : (pixel[2] + warmthInt > 255)
          ? 255
          : (pixel[2] + warmthInt);

      pixel[1] = (pixel[1] + tintInt < 0)
          ? 0
          : (pixel[1] + tintInt > 255)
          ? 255
          : (pixel[1] + tintInt);

      pixel[2] = (pixel[2] + tintInt < 0)
          ? 0
          : (pixel[2] + tintInt > 255)
          ? 255
          : (pixel[2] - tintInt);
    });
    final output = await cv.cvtColorAsync(lab, cv.COLOR_Lab2BGR);
    return output;
  }

  Future<Uint8List> lookUpTable(double gamma) async {
    final lut = Uint8List(256);
    for (int i = 0; i < 256; i++) {
      final correction = pow((i / 255.0), (1.0 / gamma)) * 255.0;
      lut[i] = correction.round().clamp(0, 255);
    }
    return lut;
  }

  Future<cv.Mat> gammaTransform({
    required cv.Mat input,
    required double gamma,
  }) async {
    final lut = await lookUpTable(gamma);
    input.forEachPixel((row, col, pixel) {
      pixel[0] = lut[pixel[0].toInt()];
      pixel[1] = lut[pixel[1].toInt()];
      pixel[2] = lut[pixel[2].toInt()];
    });
    return input;
  }

  Future<cv.Mat> chromaTransform({
    required cv.Mat input,
    required double chroma,
  }) async {
    final ycrcb = await cv.cvtColorAsync(input, cv.COLOR_BGR2HSV);

    final chromaInt = chroma.toInt();
    ycrcb.forEachPixel((row, col, pixel) {
      pixel[1] = (pixel[1] + chromaInt < 0)
          ? 0
          : (pixel[1] + chromaInt > 255)
          ? 255
          : (pixel[1] + chromaInt);
    });
    final output = await cv.cvtColorAsync(ycrcb, cv.COLOR_HSV2BGR);

    return output;
  }

  Future<Uint8List> colorCorrection({
    required Uint8List input,
    required double brightness,
    required double warmth,
    required double tint,
    required double alpha,
    required double beta,
    required double gamma,
    required double chroma,
  }) async {
    cv.Mat image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    image = await linearTransform(input: image, alpha: alpha, beta: beta);
    image = await labTransform(
      input: image,
      brightness: brightness,
      warmth: warmth,
      tint: tint,
    );
    image = await gammaTransform(input: image, gamma: gamma);
    image = await chromaTransform(input: image, chroma: chroma);

    final encode = (await cv.imencodeAsync(".png", image)).$2;
    return encode;
  }
}
