import '../entities/camera_frame_metrics.dart';
import '../entities/camera_health_evaluation.dart';

class CameraHealthEvaluator {
  const CameraHealthEvaluator();

  CameraHealthEvaluation notReady() {
    return const CameraHealthEvaluation(
      issues: [CameraHealthIssue.cameraNotReady],
    );
  }

  CameraHealthEvaluation analyzeFailed() {
    return const CameraHealthEvaluation(
      issues: [CameraHealthIssue.analyzeFailed],
    );
  }

  CameraHealthEvaluation evaluateMetrics(CameraFrameMetrics metrics) {
    final issues = <CameraHealthIssue>[];

    final blurThreshold = metrics.brightness < 30 ? 0.03 : 0.07;
    if (metrics.blurScore < blurThreshold) {
      issues.add(CameraHealthIssue.movementTooFast);
    }

    if (metrics.brightness < 30) {
      issues.add(CameraHealthIssue.lowLight);
    }

    if (metrics.darkRatio > 85) {
      issues.add(CameraHealthIssue.lensBlocked);
    }

    return CameraHealthEvaluation(
      metrics: metrics,
      issues: issues,
    );
  }
}
