import 'package:flutter/services.dart';
import 'package:dartcv4/dartcv.dart' as cv;

/*
  TODO: Add rotating image features
  TODO: Convert color to Red, Blue, Green and Grayscale channels
  TODO: Add cropping image features
  TODO: Add color adjustment features
 */
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
}
