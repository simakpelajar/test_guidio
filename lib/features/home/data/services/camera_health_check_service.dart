import 'dart:async';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

import '../../domain/entities/camera_health_evaluation.dart';
import '../../domain/services/camera_frame_analyzer.dart';
import '../../domain/services/camera_health_evaluator.dart';
import '../../../../shared/core/infrastructure/app_logger.dart';

class CameraHealthCheckService {
  CameraHealthCheckService({
    CameraFrameAnalyzer frameAnalyzer = const CameraFrameAnalyzer(),
    CameraHealthEvaluator healthEvaluator = const CameraHealthEvaluator(),
  })  : _frameAnalyzer = frameAnalyzer,
        _healthEvaluator = healthEvaluator;

  final CameraFrameAnalyzer _frameAnalyzer;
  final CameraHealthEvaluator _healthEvaluator;
  final _log = getLogger('CameraHealthCheckService');

  Future<CameraHealthEvaluation> evaluate(CameraController? controller) async {
    if (controller == null || !controller.value.isInitialized) {
      return _healthEvaluator.notReady();
    }

    try {
      await Future.delayed(const Duration(milliseconds: 180));
      final image = await controller.takePicture();
      final bytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        return _healthEvaluator.analyzeFailed();
      }

      final metrics = _frameAnalyzer.analyze(decodedImage);
      _log.info(
        'Frame analysis completed (blur=${metrics.blurScore}, darkRatio=${metrics.darkRatio}, brightness=${metrics.brightness})',
      );

      return _healthEvaluator.evaluateMetrics(metrics);
    } catch (error, stackTrace) {
      _log.warning('Frame analysis failed', error, stackTrace);
      return _healthEvaluator.analyzeFailed();
    }
  }
}
