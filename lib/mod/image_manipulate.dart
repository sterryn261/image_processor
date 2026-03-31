import 'dart:math';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:dartcv4/dartcv.dart' as cv;

/// Gồm những hàm chuyển đổi và chỉnh sửa màu sắc cơ bản.
/// []
class ImageManipulate {
  /// Chuyển đổi giá trị màu sắc của [input] từ BGR sang Grayscale (Xám) sử dụng hàm cvtColor của OpenCV.
  Future<Uint8List> grayscaleImage({required Uint8List input}) async {
    final image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    final gray = await cv.cvtColorAsync(image, cv.COLOR_BGR2GRAY);

    final encode = (await cv.imencodeAsync(".png", gray)).$2;
    return encode;
  }

  /// Tắt các giá trị màu BGR của [input] ngoại trừ giá trị màu [channel] được lựa chọn.
  ///
  /// Hàm sẽ chạy qua từng pixel trong [input] và điều chỉnh các giá trị màu không thuộc [channel] về 0.
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

  /// Tìm đường viền của các hình khối trong [input].
  ///
  /// Hiện chưa có tính năng mở rộng gì thêm.
  Future<Uint8List> edgeDetection({required Uint8List input}) async {
    final image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    final canny = cv.canny(image, image.height / 1.0, image.width / 1.0);

    final encode = (await cv.imencodeAsync(".png", canny)).$2;
    return encode;
  }

  /// Xoay [input] theo chiều kim đồng hồ khi giá trị của [direction] là false, xoay theo chiều ngược kim đồng hồ với trường hợp ngược lại
  ///
  /// Sử dụng hàm có sẳn rotate() của OpenCV, tuy nhiên có thể hiểu thuật toán của nó như sau:
  /// Tạo một ma trận ảnh Mat mới với kích thước tương đương (n, m), sau đó sao chép từng pixel tại (i, j) sang (n - j + 1, i) với chiều kim đồng hồ, (j, n - j + 1) với chiều ngược kim đồng hồ.
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

  /// Lât ngược [input] đối xứng theo trục y
  ///
  /// Sử dụng hàm có sẳn flip() của OpenCV, tuy nhiên có thể hiểu thuật toán của nó như sau:
  /// Tạo một ma trận ảnh Mat mới với kích thước tương đương (n, m), sau đó sao chép từng pixel tại (i, j) sang (n - i + 1, j);
  Future<Uint8List> flip({required Uint8List input}) async {
    final image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);

    final flipImage = cv.flip(image, 1);

    final encode = (await cv.imencodeAsync(".png", flipImage)).$2;
    return encode;
  }

  /// Chỉnh sửa độ tương phản và độ sáng (không ưu tiên) của [input] theo phương trình tuyến tính f(y) = [alpha] * f(x) + [beta] với hàm f(x) là giá trị màu BGR của pixel x(i, j).
  ///
  /// * [alpha] đại diện cho độ tương phản
  /// * [beta] đại diện cho độ sáng *không ưu tiên
  ///
  /// *Độ sáng không ưu tiên tức độ sáng không được điều chỉnh để phù hợp với mắt người, do mắt người có cảm giác sáng hơn với một số màu sắc như vàng. Vì thế nên khi chỉnh [beta], ta có cảm giác những màu sáng bị đấy sáng hơn bình thường
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

  /// Chỉnh sửa độ sáng (ưu tiên), độ ấm, sắc thái màu của [input] theo hệ màu Lab.
  ///
  /// * [luminance] đại diện cho độ sáng *ưu tiên
  /// * [warmth] đại diện cho độ ấm của màu, bằng cách chỉnh 2 thông số a và b cùng chiều
  /// * [tint] đại diện cho sắc thái của màu, bằng cách chỉnh 2 thông số a và b ngược chiều
  ///
  /// *Độ sáng ưu tiên tức độ sáng được điều chỉnh để phù hợp với mắt người, do mắt người có cảm giác sáng hơn với một số màu sắc như vàng. Vì thế nên khi chỉnh [luminance], ánh sáng trông sẽ tự nhiên hơn.
  Future<cv.Mat> labTransform({
    required cv.Mat input,
    required double luminance,
    required double warmth,
    required double tint,
  }) async {
    final lab = await cv.cvtColorAsync(input, cv.COLOR_BGR2Lab);
    lab.forEachPixel((row, col, pixel) {
      final brightnessInt = luminance.round();
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

  /// Tính toán sẵn các giá trị của [gamma]
  Future<Uint8List> lookUpTable(double gamma) async {
    final lut = Uint8List(256);
    for (int i = 0; i < 256; i++) {
      final correction = pow((i / 255.0), (1.0 / gamma)) * 255.0;
      lut[i] = correction.round().clamp(0, 255);
    }
    return lut;
  }

  /// Chỉnh sửa vùng sáng của [input].
  ///
  /// * [gamma] đại diện cho mức độ của vùng sáng
  ///
  /// Về cơ bản, nó tuần theo phương trình $V_{\text{out}}=AV_{\text{in}}^{\gamma }$, ưu tiên độ sáng của những vùng sáng cao hơn những vùng tối.
  /// Gia trị được tính sẵn trong hàm lookuptable()
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

  /// Chỉnh sửa độ bão hòa của [input] thông qua giá trị Saturation [chroma] của hệ màu HSV của pixel (i, j).
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

  /// Chỉnh sửa các thông số ảnh của [input] thông qua các giá trị được nạp vào.
  ///
  /// Thông tin chi tiết vui lòng xem các hàm bên trong nó
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
      luminance: brightness,
      warmth: warmth,
      tint: tint,
    );
    image = await gammaTransform(input: image, gamma: gamma);
    image = await chromaTransform(input: image, chroma: chroma);

    final encode = (await cv.imencodeAsync(".png", image)).$2;
    return encode;
  }

  Future<Uint8List> reduceResolution({required Uint8List input}) async {
    cv.Mat image = await cv.imdecodeAsync(input, cv.IMREAD_COLOR);
    if (image.cols * image.rows > 1000000) {
      image = cv.pyrDown(image);
    }

    final encode = (await cv.imencodeAsync(".png", image)).$2;
    return encode;
  }
}
