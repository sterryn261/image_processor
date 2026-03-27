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
}
