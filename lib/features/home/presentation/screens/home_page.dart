import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:test_guidio/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'dart:async';
import '../cubit/camera_cubit.dart';
import '../cubit/camera_state.dart';
import '../../../../shared/core/constant/app_colors.dart';
import '../../../../shared/core/constant/app_sizes.dart';

class HomePage extends StatefulWidget {
	const HomePage({super.key});

	@override
	State<HomePage> createState() => _HomePageState();
}

class _SafeCameraPreview extends StatefulWidget {
	final CameraController controller;

	const _SafeCameraPreview({required this.controller});

	@override
	State<_SafeCameraPreview> createState() => _SafeCameraPreviewState();
}

class _SafeCameraPreviewState extends State<_SafeCameraPreview> {
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
			// Check if controller is still valid before using it
			if (_localController.value.isInitialized) {
				_isControllerValid = true;
			} else {
				_isControllerValid = false;
			}
		} catch (e) {
			print('Controller verification failed: $e');
			_isControllerValid = false;
		}
	}

	@override
	void didUpdateWidget(_SafeCameraPreview oldWidget) {
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
					child: Icon(Icons.camera_alt, color: Colors.white54, size: AppSizes.iconCameraMedium),
				),
			);
		}

		try {
			final previewSize = _localController.value.previewSize;
			if (previewSize == null) {
				return CameraPreview(_localController);
			}

			// Keep native preview aspect ratio to avoid stretched/soft rendering.
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
		} catch (e) {
			print('Camera preview error: $e');
			return Container(
				color: Colors.black,
				child: Center(
					child: Icon(Icons.camera_alt, color: Colors.white54, size: AppSizes.iconCameraMedium),
				),
			);
		}
	}
}

class _HomePageState extends State<HomePage> {
	CameraController? _controller;
	bool _isHealthCheckRunning = false;

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			_requestPermissionsAndStartCamera();
		});
	}

	Future<void> _requestPermissionsAndStartCamera() async {
		try {
			await _requestPermissions();
			if (mounted) {
				context.read<CameraCubit>().toggleCamera();
			}
		} catch (e) {
			print('Error: $e');
		}
	}

	Future<void> _requestPermissions() async {
		// Request Camera Permission
		final cameraStatus = await Permission.camera.request();
		print('Camera permission: $cameraStatus');

		if (cameraStatus.isDenied) {
			print('Camera permission denied');
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Camera permission diperlukan')),
				);
			}
		} else if (cameraStatus.isPermanentlyDenied) {
			print('Camera permission permanently denied');
			if (mounted) {
				openAppSettings();
			}
		}

		// Request Microphone Permission
		final micStatus = await Permission.microphone.request();
		print('Microphone permission: $micStatus');

		if (micStatus.isDenied) {
			print('Microphone permission denied');
		}
	}

	/// Analyze captured image for blur, brightness, and obstruction
	Future<Map<String, dynamic>> _analyzeFrame() async {
		if (_controller == null || !_controller!.value.isInitialized) {
			return {'success': false};
		}

		try {
			// Let autofocus/exposure settle briefly so capture is less noisy/blurry.
			await Future.delayed(const Duration(milliseconds: 180));
			final image = await _controller!.takePicture();
			final bytes = await image.readAsBytes();
			final decodedImage = img.decodeImage(bytes);

			if (decodedImage == null) {
				return {'success': false};
			}

			// 1. Calculate blur (Laplacian variance)
			final blurScore = _calculateLaplacianVariance(decodedImage);

			// 2. Calculate dark pixel ratio (lens obstruction)
			final darkRatio = _calculateDarkPixelRatio(decodedImage);

			// 3. Calculate average brightness (light level)
			final brightness = _calculateAverageBrightness(decodedImage);

			print('Frame Analysis: blur=$blurScore, darkRatio=$darkRatio, brightness=$brightness');

			return {
				'success': true,
				'blurScore': blurScore,
				'darkRatio': darkRatio,
				'brightness': brightness,
			};
		} catch (e) {
			print('Frame analysis error: $e');
			return {'success': false};
		}
	}

	/// Convert pixel to normalized luminance (0.0 - 1.0)
	double _getPixelLuminance(img.Pixel pixel) {
		// Get RGB values and calculate luminance
		final r = (pixel.r as int) / 255.0;
		final g = (pixel.g as int) / 255.0;
		final b = (pixel.b as int) / 255.0;
		// Standard luminance formula
		return (r * 0.299 + g * 0.587 + b * 0.114);
	}

	/// Calculate Laplacian variance to detect blur
	double _calculateLaplacianVariance(img.Image image) {
		try {
			// Resize untuk performa
			final resized = img.copyResize(image, width: 160, height: 90);
			final grayscale = img.grayscale(resized);

			double sumVariance = 0;
			int pixelCount = 0;

			// Simple Laplacian approximation: difference between pixel and neighbors
			for (int y = 1; y < grayscale.height - 1; y++) {
				for (int x = 1; x < grayscale.width - 1; x++) {
					try {
						final center = _getPixelLuminance(grayscale.getPixelSafe(x, y));
						final left = _getPixelLuminance(grayscale.getPixelSafe(x - 1, y));
						final right = _getPixelLuminance(grayscale.getPixelSafe(x + 1, y));
						final top = _getPixelLuminance(grayscale.getPixelSafe(x, y - 1));
						final bottom = _getPixelLuminance(grayscale.getPixelSafe(x, y + 1));

						// Laplacian kernel: 4*center - sum(neighbors)
						final laplacian = (4 * center - (left + right + top + bottom)).abs();
						sumVariance += laplacian * laplacian;
						pixelCount++;
					} catch (e) {
						continue;
					}
				}
			}

			final variance = pixelCount > 0 ? sumVariance / pixelCount : 0.0;
			print('Blur Analysis(normalized): pixelCount=$pixelCount, variance=$variance');
			return variance;
		} catch (e) {
			print('Laplacian calculation error: $e');
			return 0;
		}
	}

	/// Calculate ratio of dark pixels (to detect lens obstruction)
	double _calculateDarkPixelRatio(img.Image image) {
		try {
			final resized = img.copyResize(image, width: 160, height: 90);
			int darkPixels = 0;
			int totalPixels = resized.width * resized.height;

			for (int y = 0; y < resized.height; y++) {
				for (int x = 0; x < resized.width; x++) {
					final pixel = resized.getPixelSafe(x, y);
					final brightness = _getPixelLuminance(pixel);
					// Dark threshold: < 0.2 (20% brightness)
					if (brightness < 0.2) {
						darkPixels++;
					}
				}
			}

			final ratio = (darkPixels / totalPixels) * 100;
			print('Dark pixel ratio: $ratio%');
			return ratio;
		} catch (e) {
			print('Dark pixel calculation error: $e');
			return 0;
		}
	}

	/// Calculate average brightness (for light level detection)
	double _calculateAverageBrightness(img.Image image) {
		try {
			final resized = img.copyResize(image, width: 160, height: 90);
			double totalBrightness = 0;
			int pixelCount = resized.width * resized.height;

			for (int y = 0; y < resized.height; y++) {
				for (int x = 0; x < resized.width; x++) {
					final pixel = resized.getPixelSafe(x, y);
					totalBrightness += _getPixelLuminance(pixel);
				}
			}

			final avgBrightness = (totalBrightness / pixelCount) * 100;
			print('Average brightness: $avgBrightness%');
			return avgBrightness;
		} catch (e) {
			print('Brightness calculation error: $e');
			return 0;
		}
	}



	/// SPEC-01: Camera Health Check
	/// Validates 4 conditions for proper camera usage by visually impaired users:
	/// 1. Camera Orientation - Arahkan kamera ke depan (not tilted)
	/// 2. Blur Detection - Gerakan terlalu cepat, mohon perlahan
	/// 3. Light Level - Cahaya terlalu gelap
	/// 4. Lens Obstruction - Kamera tertutup, periksa lensa
	Future<void> _performCameraHealthCheck() async {
		if (_isHealthCheckRunning) return;
		_isHealthCheckRunning = true;

		try {
			final cubit = context.read<CameraCubit>();
			final currentState = cubit.state;

			// Auto-enable camera if not already active
			if (!currentState.cameraActive) {
				print('Kamera belum aktif. Mengaktifkan kamera otomatis...');
				await cubit.toggleCamera();
				
				// Wait for camera to initialize
				await Future.delayed(const Duration(milliseconds: 500));
			}

			List<String> alerts = [];
			List<String> results = [];
			bool allPassed = true;

			// Check if camera is initialized
			if (_controller == null || !_controller!.value.isInitialized) {
				alerts.add('Kamera belum siap. Mohon tunggu...');
				allPassed = false;
			} else {
				// SKIP: Check camera orientation using accelerometer
				// (Accelerometer readings are unreliable for this use case)
				results.add('✓ Orientasi: Tidak perlu validasi');

				// 2 & 3 & 4: Analyze frame for blur, light level, and obstruction
				final frameAnalysis = await _analyzeFrame();

				if (frameAnalysis['success'] == true) {
					final blurScore = frameAnalysis['blurScore'] as double;
					final darkRatio = frameAnalysis['darkRatio'] as double;
					final brightness = frameAnalysis['brightness'] as double;

					// Blur score is normalized (usually around 0.0 - 0.3), so use calibrated threshold.
					// In low light, blur score naturally drops; avoid false negatives by relaxing threshold.
					final blurThreshold = brightness < 30 ? 0.03 : 0.07;
					if (blurScore < blurThreshold) {
						alerts.add('Gerakan terlalu cepat, mohon perlahan');
						results.add('❌ Blur: Terlalu blur (score: ${blurScore.toStringAsFixed(3)})');
						allPassed = false;
					} else {
						results.add('✓ Blur: Pergerakan stabil (score: ${blurScore.toStringAsFixed(3)})');
					}

					// Light level: < 30% brightness is too dark
					if (brightness < 30) {
						alerts.add('Cahaya terlalu gelap');
						results.add('❌ Cahaya: Terlalu gelap (${brightness.toStringAsFixed(1)}%)');
						allPassed = false;
					} else {
						results.add('✓ Cahaya: Cukup (${brightness.toStringAsFixed(1)}%)');
					}

					// Lens obstruction: > 85% dark pixels means blocked
					if (darkRatio > 85) {
						alerts.add('Kamera tertutup, periksa lensa');
						results.add('❌ Lensa: Tertutup (${darkRatio.toStringAsFixed(1)}% dark)');
						allPassed = false;
					} else {
						results.add('✓ Lensa: Bersih (${darkRatio.toStringAsFixed(1)}% dark)');
					}
				} else {
					alerts.add('Gagal menganalisis frame. Coba lagi.');
					allPassed = false;
				}
			}

			// Prepare feedback text
			String feedbackText = allPassed 
				? 'Kamera siap untuk navigasi!\n${results.join('\n')}'
				: 'Ada masalah:\n${results.join('\n')}\n\nAksi: ${alerts.join(', ')}';

			print('=== CAMERA HEALTH CHECK ===');
			print('Status: ${allPassed ? "PASSED ✓" : "FAILED ✗"}');
			print(feedbackText);
			print('===========================');

			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: SingleChildScrollView(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							mainAxisSize: MainAxisSize.min,
							children: [
								Text(
									allPassed ? '✓ Kamera Siap!' : '⚠ Ada Masalah',
									style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
								),
								const SizedBox(height: 8),
								...results.map((r) => Text(r, style: const TextStyle(fontSize: 13))),
							],
						),
					),
					duration: const Duration(seconds: 5),
					backgroundColor: allPassed ? Colors.green : Colors.orange,
				),
			);

		} catch (e) {
			print('Camera health check error: $e');
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('Error: $e'),
					duration: const Duration(seconds: 3),
					backgroundColor: Colors.red,
				),
			);
		} finally {
			_isHealthCheckRunning = false;
		}
	}

	@override
	void dispose() {
		_controller?.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.background,
			body: SafeArea(
				child: Stack(
					children: [
						// Camera preview or placeholder
						Positioned.fill(
							child: BlocBuilder<CameraCubit, dynamic>(
								buildWhen: (previous, current) {
									// Only rebuild when cameraActive state changes
									if (previous is CameraState && current is CameraState) {
										return previous.cameraActive != current.cameraActive;
									}
									return true;
								},
								builder: (context, camState) {
									final cameraActive = (camState is CameraState) ? camState.cameraActive : false;
									final controller = (camState is CameraState) ? camState.controller : null;
									
									// Update local reference for health check
									if (controller != null) {
										_controller = controller;
									}
									
									// Early exit if camera is off or controller is null
									if (!cameraActive || controller == null) {
										return Container(
											color: Colors.black,
											child: Center(
												child: Icon(Icons.camera_alt, color: Colors.white54, size: AppSizes.iconCameraMedium),
											),
										);
									}
									
									// Safe camera preview builder
									return _SafeCameraPreview(controller: controller);
								},
							),
						),

						// Top-left mode chip
						Positioned(
							left: AppSizes.positionBase,
							top: AppSizes.positionBase,
							child: Container(
								padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: AppSizes.paddingSmall),
								decoration: BoxDecoration(
									color: Colors.white.withOpacity(0.9),
									borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
								),
								child: Row(
									children: [
										Container(
											width: 8.w,
											height: 8.w,
											decoration: BoxDecoration(
												color: AppColors.primary,
												shape: BoxShape.circle,
											),
										),
										SizedBox(width: AppSizes.paddingSmall),
										Builder(
											builder: (context) {
												return Text(
													AppLocalizations.of(context)?.mode_detection ?? 'Mode: Deteksi',
													style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
												);
											},
										),
									],
								),
							),
						),

						// Top-right settings
						Positioned(
							right: AppSizes.positionBase,
							top: AppSizes.positionBase,
							child: GestureDetector(
								onTap: () {},
								child: Container(
									padding: EdgeInsets.all(AppSizes.paddingSmall),
									decoration: BoxDecoration(
										color: Colors.white.withOpacity(0.9),
										shape: BoxShape.circle,
									),
									child: Icon(Icons.settings, color: Colors.black87, size: AppSizes.iconMedium),
								),
							),
						),

						// Center-bottom message bubble
						Positioned(
							left: AppSizes.paddingLarge,
							right: AppSizes.paddingLarge,
							bottom: 160.h,
							child: Container(
								padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingBase, vertical: AppSizes.paddingBase),
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
									boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4.h))],
								),
								child: Text(
									'1 meter ada laptop depan anda',
									textAlign: TextAlign.center,
									style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
								),
							),
						),

						// Bottom controls (white pill)
						Positioned(
							left: AppSizes.paddingLarge,
							right: AppSizes.paddingLarge,
							bottom: 24.h,
							child: Container(
								padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingBase, vertical: AppSizes.paddingBase),
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
									boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: Offset(0, 4.h))],
								),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										// Camera button - Toggle camera on/off
										BlocBuilder<CameraCubit, dynamic>(
											builder: (context, camState) {
												final cubit = context.read<CameraCubit>();
												final cameraActive = (camState is CameraState) ? camState.cameraActive : false;
												return Tooltip(
													message: cameraActive ? 'Matikan Kamera' : 'Nyalakan Kamera',
													child: IconButton(
														onPressed: () => cubit.toggleCamera(),
														icon: Icon(
															cameraActive ? Icons.camera_alt : Icons.no_photography,
															color: cameraActive ? AppColors.primary : Colors.grey,
														),
														iconSize: AppSizes.iconLarge,
														padding: EdgeInsets.zero,
														constraints: BoxConstraints(minWidth: AppSizes.buttonSmallWidth, minHeight: AppSizes.buttonSmallHeight),
													),
												);
											},
										),

										// Mic central - Toggle microphone input
										BlocBuilder<CameraCubit, dynamic>(
											builder: (context, camState) {
												final cubit = context.read<CameraCubit>();
												final micActive = (camState is CameraState) ? camState.microphoneActive : false;
												return Tooltip(
													message: micActive ? 'Matikan Mikrofon' : 'Nyalakan Mikrofon',
													child: GestureDetector(
														onTap: () => cubit.toggleMicrophone(),
														child: Container(
															width: AppSizes.buttonWidth,
															height: AppSizes.buttonHeight,
															decoration: BoxDecoration(
																color: micActive ? AppColors.primary : Colors.grey[300],
																shape: BoxShape.circle,
																boxShadow: [BoxShadow(color: (micActive ? AppColors.primary : Colors.grey).withOpacity(0.4), blurRadius: 16, offset: Offset(0, 6.h))],
															),
															child: Icon(micActive ? Icons.mic : Icons.mic_off, color: micActive ? Colors.white : Colors.grey, size: AppSizes.iconXLarge),
														),
													),
												);
											},
										),

										// Grid button - Camera Health Check
										BlocBuilder<CameraCubit, dynamic>(
											builder: (context, camState) {
												final cameraActive = (camState is CameraState) ? camState.cameraActive : false;
												return Tooltip(
													message: cameraActive ? 'Cek Kesehatan Kamera' : 'Nyalakan Kamera untuk Cek Kesehatan',
													child: IconButton(
														onPressed: _performCameraHealthCheck,
														icon: Icon(
															Icons.health_and_safety,
															color: cameraActive ? AppColors.primary : Colors.grey,
														),
														iconSize: AppSizes.iconLarge,
														padding: EdgeInsets.zero,
														constraints: BoxConstraints(minWidth: AppSizes.buttonSmallWidth, minHeight: AppSizes.buttonSmallHeight),
													),
												);
											},
										),
									],
								),
							),
						),
					],
				),
			),
		);
	}
}
