import 'package:camera/camera.dart';

class CameraState {
  final bool cameraActive;
  final bool microphoneActive;
  final CameraController? controller;
  
  CameraState({
    required this.cameraActive,
    required this.microphoneActive,
    this.controller,
  });

  CameraState copyWith({
    bool? cameraActive,
    bool? microphoneActive,
    CameraController? controller,
  }) =>
      CameraState(
        cameraActive: cameraActive ?? this.cameraActive,
        microphoneActive: microphoneActive ?? this.microphoneActive,
        controller: controller ?? this.controller,
      );

  static CameraState initial() => CameraState(
    cameraActive: false,
    microphoneActive: false,
    controller: null,
  );
}
