import 'package:image/image.dart' as img;

import '../entities/camera_frame_metrics.dart';

class CameraFrameAnalyzer {
  const CameraFrameAnalyzer();

  CameraFrameMetrics analyze(img.Image image) {
    final blurScore = _calculateLaplacianVariance(image);
    final darkRatio = _calculateDarkPixelRatio(image);
    final brightness = _calculateAverageBrightness(image);

    return CameraFrameMetrics(
      blurScore: blurScore,
      darkRatio: darkRatio,
      brightness: brightness,
    );
  }

  double _getPixelLuminance(img.Pixel pixel) {
    final r = (pixel.r as int) / 255.0;
    final g = (pixel.g as int) / 255.0;
    final b = (pixel.b as int) / 255.0;
    return (r * 0.299 + g * 0.587 + b * 0.114);
  }

  double _calculateLaplacianVariance(img.Image image) {
    try {
      final resized = img.copyResize(image, width: 160, height: 90);
      final grayscale = img.grayscale(resized);

      double sumVariance = 0;
      int pixelCount = 0;

      for (int y = 1; y < grayscale.height - 1; y++) {
        for (int x = 1; x < grayscale.width - 1; x++) {
          final center = _getPixelLuminance(grayscale.getPixelSafe(x, y));
          final left = _getPixelLuminance(grayscale.getPixelSafe(x - 1, y));
          final right = _getPixelLuminance(grayscale.getPixelSafe(x + 1, y));
          final top = _getPixelLuminance(grayscale.getPixelSafe(x, y - 1));
          final bottom = _getPixelLuminance(grayscale.getPixelSafe(x, y + 1));

          final laplacian = (4 * center - (left + right + top + bottom)).abs();
          sumVariance += laplacian * laplacian;
          pixelCount++;
        }
      }

      return pixelCount > 0 ? sumVariance / pixelCount : 0.0;
    } catch (_) {
      return 0;
    }
  }

  double _calculateDarkPixelRatio(img.Image image) {
    try {
      final resized = img.copyResize(image, width: 160, height: 90);
      int darkPixels = 0;
      final totalPixels = resized.width * resized.height;

      for (int y = 0; y < resized.height; y++) {
        for (int x = 0; x < resized.width; x++) {
          final pixel = resized.getPixelSafe(x, y);
          final brightness = _getPixelLuminance(pixel);
          if (brightness < 0.2) {
            darkPixels++;
          }
        }
      }

      return (darkPixels / totalPixels) * 100;
    } catch (_) {
      return 0;
    }
  }

  double _calculateAverageBrightness(img.Image image) {
    try {
      final resized = img.copyResize(image, width: 160, height: 90);
      double totalBrightness = 0;
      final pixelCount = resized.width * resized.height;

      for (int y = 0; y < resized.height; y++) {
        for (int x = 0; x < resized.width; x++) {
          final pixel = resized.getPixelSafe(x, y);
          totalBrightness += _getPixelLuminance(pixel);
        }
      }

      return (totalBrightness / pixelCount) * 100;
    } catch (_) {
      return 0;
    }
  }
}
