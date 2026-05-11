import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../shared/core/constant/app_sizes.dart';
import '../../../../shared/core/infrastructure/app_logger.dart';

final _log = getLogger('SafeCameraPreview');

class SafeCameraPreview extends StatefulWidget {
  final CameraController controller;

  const SafeCameraPreview({
    required this.controller,
    super.key,
  });

  @override
  State<SafeCameraPreview> createState() => _SafeCameraPreviewState();
}

class _SafeCameraPreviewState extends State<SafeCameraPreview> {
  late CameraController _localController;
  bool _isControllerValid = true;

  @override
  void initState() {
    super.initState();
    _localController = widget.controller;
    _verifyController();
  }

  void _verifyController() {
    try {
      _isControllerValid = _localController.value.isInitialized;
    } catch (error, stackTrace) {
      _log.warning('Controller verification failed', error, stackTrace);
      _isControllerValid = false;
    }
  }

  @override
  void didUpdateWidget(SafeCameraPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _localController = widget.controller;
      _verifyController();
    }
  }

  @override
  Widget build(BuildContext context) {
    _verifyController();

    if (!_isControllerValid) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.camera_alt,
            color: Colors.white54,
            size: AppSizes.iconCameraMedium,
          ),
        ),
      );
    }

    try {
      final previewSize = _localController.value.previewSize;
      if (previewSize == null) {
        return CameraPreview(_localController);
      }

      return ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: CameraPreview(_localController),
            ),
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.warning('Camera preview render failed', error, stackTrace);
      return Container(
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.camera_alt,
            color: Colors.white54,
            size: AppSizes.iconCameraMedium,
          ),
        ),
      );
    }
  }
}
