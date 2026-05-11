import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraCubit() : super(CameraState.initial());

  Future<void> _initCamera() async {
    if (state.controller != null && state.controller!.value.isInitialized) {
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
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
      emit(state.copyWith(controller: controller));
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> toggleCamera() async {
    try {
      final camStatus = await Permission.camera.status;
      
      if (camStatus.isDenied) {
        print('Camera permission denied, requesting...');
        final newStatus = await Permission.camera.request();
        if (!newStatus.isGranted) {
          print('Camera permission not granted');
          return;
        }
      } else if (camStatus.isPermanentlyDenied) {
        print('Camera permission permanently denied, opening settings');
        openAppSettings();
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
            print('Camera disposed successfully');
          } catch (e) {
            print('Error disposing camera: $e');
          }
        }
      } else {
        // Turn on camera
        print('Initializing camera...');
        await _initCamera();
        emit(state.copyWith(cameraActive: true));
        print('Camera initialized and active');
      }
    } catch (e) {
      print('Error in toggleCamera: $e');
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
    try {
      await state.controller?.dispose();
    } catch (_) {}
    emit(CameraState.initial());
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
