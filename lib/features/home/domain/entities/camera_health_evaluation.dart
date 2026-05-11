import 'camera_frame_metrics.dart';

enum CameraHealthIssue {
  cameraNotReady,
  analyzeFailed,
  movementTooFast,
  lowLight,
  lensBlocked,
}

class CameraHealthEvaluation {
  final CameraFrameMetrics? metrics;
  final List<CameraHealthIssue> issues;

  const CameraHealthEvaluation({
    required this.issues,
    this.metrics,
  });

  bool get isPassed => issues.isEmpty;
}
