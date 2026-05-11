import 'package:camera/camera.dart';

class CameraState {
  static const Object _noControllerUpdate = Object();

  final bool cameraActive;
  final bool microphoneActive;
  final bool cameraBusy;
  final CameraController? controller;
  
  CameraState({
    required this.cameraActive,
    required this.microphoneActive,
    required this.cameraBusy,
    this.controller,
  });

  CameraState copyWith({
    bool? cameraActive,
    bool? microphoneActive,
    bool? cameraBusy,
    Object? controller = _noControllerUpdate,
  }) =>
      CameraState(
        cameraActive: cameraActive ?? this.cameraActive,
        microphoneActive: microphoneActive ?? this.microphoneActive,
        cameraBusy: cameraBusy ?? this.cameraBusy,
        controller: identical(controller, _noControllerUpdate)
            ? this.controller
            : controller as CameraController?,
      );

  static CameraState initial() => CameraState(
    cameraActive: false,
    microphoneActive: false,
    cameraBusy: false,
    controller: null,
  );
}
