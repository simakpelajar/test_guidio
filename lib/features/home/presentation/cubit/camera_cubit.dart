import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../shared/core/infrastructure/app_logger.dart';
import 'camera_state.dart';

final _log = getLogger('CameraCubit');

class CameraCubit extends Cubit<CameraState> {
  CameraCubit() : super(CameraState.initial());

  bool _isTogglingCamera = false;

  Future<CameraController?> _initCamera() async {
    if (state.controller != null && state.controller!.value.isInitialized) {
      return state.controller;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;
      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Use high resolution for clear preview, keep audio off to reduce load/heat.
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setFlashMode(FlashMode.off);

      // Cubit may be closed while async init is in progress.
      if (isClosed) {
        await controller.dispose();
        return null;
      }

      return controller;
    } catch (e) {
      _log.severe('Error initializing camera', e);
      return null;
    }
  }

  Future<void> toggleCamera() async {
    if (_isTogglingCamera || isClosed) return;
    _isTogglingCamera = true;
    emit(state.copyWith(cameraBusy: true));

    try {
      final camStatus = await Permission.camera.status;
      
      if (camStatus.isDenied) {
        _log.info('Camera permission denied, requesting');
        final newStatus = await Permission.camera.request();
        if (!newStatus.isGranted) {
          _log.warning('Camera permission not granted');
          emit(state.copyWith(cameraBusy: false));
          return;
        }
      } else if (camStatus.isPermanentlyDenied) {
        _log.warning('Camera permission permanently denied, opening settings');
        openAppSettings();
        emit(state.copyWith(cameraBusy: false));
        return;
      }

      if (state.cameraActive) {
        // Turn off camera - EMIT FIRST to clear state
        final oldController = state.controller;
        emit(state.copyWith(cameraActive: false, controller: null));
        
        // THEN dispose old controller safely
        if (oldController != null) {
          try {
            await oldController.dispose();
            await Future.delayed(const Duration(milliseconds: 120));
            _log.info('Camera disposed successfully');
          } catch (e) {
            _log.warning('Error disposing camera', e);
          }
        }

        if (!isClosed) {
          emit(state.copyWith(cameraBusy: false));
        }
      } else {
        // Turn on camera
        _log.info('Initializing camera');
        final controller = await _initCamera();
        if (controller != null && !isClosed) {
          emit(
            state.copyWith(
              cameraActive: true,
              controller: controller,
              cameraBusy: false,
            ),
          );
          _log.info('Camera initialized and active');
        } else if (!isClosed) {
          emit(state.copyWith(cameraBusy: false));
        }
      }
    } catch (e) {
      _log.severe('Error in toggleCamera', e);
      if (!isClosed) {
        emit(state.copyWith(cameraBusy: false));
      }
    } finally {
      _isTogglingCamera = false;
    }
  }

  Future<void> toggleMicrophone() async {
    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      await Permission.microphone.request();
    }

    emit(state.copyWith(microphoneActive: !state.microphoneActive));
  }

  Future<void> stopAll() async {
    if (isClosed) return;
    try {
      final oldController = state.controller;
      emit(state.copyWith(cameraActive: false, cameraBusy: true, controller: null));
      await oldController?.dispose();
    } catch (_) {}
    if (!isClosed) {
      emit(CameraState.initial());
    }
  }

  @override
  Future<void> close() async {
    await stopAll();
    return super.close();
  }
}
