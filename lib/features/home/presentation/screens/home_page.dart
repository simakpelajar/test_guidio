import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:test_guidio/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../domain/entities/camera_health_evaluation.dart';
import '../../data/services/camera_health_check_service.dart';
import '../cubit/camera_cubit.dart';
import '../cubit/camera_state.dart';
import '../widgets/safe_camera_preview.dart';
import '../../../../shared/core/constant/app_colors.dart';
import '../../../../shared/core/constant/app_sizes.dart';
import '../../../../shared/core/infrastructure/app_logger.dart';

final _log = getLogger('HomePage');

class HomePage extends StatefulWidget {
	const HomePage({super.key});

	@override
	State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	CameraController? _controller;
	bool _isHealthCheckRunning = false;
	final CameraHealthCheckService _healthCheckService = CameraHealthCheckService();

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
		} catch (e, stackTrace) {
			_log.severe('Failed to request permissions and start camera', e, stackTrace);
		}
	}

	Future<void> _requestPermissions() async {
		final l10n = AppLocalizations.of(context)!;

		// Request Camera Permission
		final cameraStatus = await Permission.camera.request();
		_log.info('Camera permission status: $cameraStatus');

		if (cameraStatus.isDenied) {
			_log.warning('Camera permission denied');
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text(l10n.camera_permission_required)),
				);
			}
		} else if (cameraStatus.isPermanentlyDenied) {
			_log.warning('Camera permission permanently denied');
			if (mounted) {
				openAppSettings();
			}
		}

		// Request Microphone Permission
		final micStatus = await Permission.microphone.request();
		_log.info('Microphone permission status: $micStatus');

		if (micStatus.isDenied) {
			_log.warning('Microphone permission denied');
		}
	}

	void _appendLocalizedHealthMessages({
		required CameraHealthEvaluation evaluation,
		required AppLocalizations l10n,
		required List<String> alerts,
		required List<String> results,
	}) {
		final metrics = evaluation.metrics;

		if (evaluation.issues.contains(CameraHealthIssue.cameraNotReady)) {
			alerts.add(l10n.camera_not_ready);
			return;
		}

		if (evaluation.issues.contains(CameraHealthIssue.analyzeFailed)) {
			alerts.add(l10n.health_analyze_failed);
			return;
		}

		if (metrics == null) return;

		if (evaluation.issues.contains(CameraHealthIssue.movementTooFast)) {
			alerts.add(l10n.health_alert_too_fast);
			results.add(l10n.health_blur_bad(metrics.blurScore.toStringAsFixed(3)));
		} else {
			results.add(l10n.health_blur_good(metrics.blurScore.toStringAsFixed(3)));
		}

		if (evaluation.issues.contains(CameraHealthIssue.lowLight)) {
			alerts.add(l10n.health_alert_dark);
			results.add(l10n.health_light_bad(metrics.brightness.toStringAsFixed(1)));
		} else {
			results.add(l10n.health_light_good(metrics.brightness.toStringAsFixed(1)));
		}

		if (evaluation.issues.contains(CameraHealthIssue.lensBlocked)) {
			alerts.add(l10n.health_alert_lens_blocked);
			results.add(l10n.health_lens_bad(metrics.darkRatio.toStringAsFixed(1)));
		} else {
			results.add(l10n.health_lens_good(metrics.darkRatio.toStringAsFixed(1)));
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
		final l10n = AppLocalizations.of(context)!;

		try {
			final cubit = context.read<CameraCubit>();
			final currentState = cubit.state;

			CameraHealthEvaluation evaluation;
			// Auto-enable camera if not already active
			if (!currentState.cameraActive) {
				_log.info('Camera inactive, enabling camera automatically before health check');
				await cubit.toggleCamera();
				
				// Wait for camera to initialize
				await Future.delayed(const Duration(milliseconds: 500));
			}

			List<String> alerts = [];
			List<String> results = [];
			bool allPassed = true;

			// Check if camera is initialized
			if (_controller == null || !_controller!.value.isInitialized) {
				evaluation = const CameraHealthEvaluation(
					issues: [CameraHealthIssue.cameraNotReady],
				);
			} else {
				// SKIP: Check camera orientation using accelerometer
				// (Accelerometer readings are unreliable for this use case)
				results.add(l10n.health_orientation_skipped);
				evaluation = await _healthCheckService.evaluate(_controller);
			}

			_appendLocalizedHealthMessages(
				evaluation: evaluation,
				l10n: l10n,
				alerts: alerts,
				results: results,
			);
			allPassed = evaluation.isPassed;

			_log.info('Camera health check completed with status: ${allPassed ? 'PASSED' : 'FAILED'}');

			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: SingleChildScrollView(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							mainAxisSize: MainAxisSize.min,
							children: [
								Text(
									allPassed ? l10n.health_ready_title : l10n.health_issues_title,
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

		} catch (e, stackTrace) {
			_log.severe('Camera health check error', e, stackTrace);
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('${l10n.error_prefix}: $e'),
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
		_controller = null;
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
									// Rebuild preview for active/controller/loading transitions.
									if (previous is CameraState && current is CameraState) {
										return previous.cameraActive != current.cameraActive ||
												previous.controller != current.controller ||
												previous.cameraBusy != current.cameraBusy;
									}
									return true;
								},
								builder: (context, camState) {
									final cameraActive = (camState is CameraState) ? camState.cameraActive : false;
									final cameraBusy = (camState is CameraState) ? camState.cameraBusy : false;
									final controller = (camState is CameraState) ? camState.controller : null;
									
									// Update local reference for health check
									if (controller != null) {
										_controller = controller;
									} else if (!cameraActive) {
										_controller = null;
									}

									final placeholder = Container(
										color: Colors.black,
										child: Center(
											child: Icon(Icons.camera_alt, color: Colors.white54, size: AppSizes.iconCameraMedium),
										),
									);

									return AnimatedSwitcher(
										duration: const Duration(milliseconds: 220),
										switchInCurve: Curves.easeOut,
										switchOutCurve: Curves.easeIn,
										child: Stack(
											key: ValueKey('${cameraActive}_${cameraBusy}_${controller?.hashCode ?? 0}'),
											fit: StackFit.expand,
											children: [
												if (cameraActive && controller != null)
													SafeCameraPreview(controller: controller)
												else
													placeholder,
												if (cameraBusy)
													Container(
															color: Colors.black.withValues(alpha: 0.55),
														child: Center(
															child: Column(
																mainAxisSize: MainAxisSize.min,
																children: [
																	SizedBox(
																		width: 28,
																		height: 28,
																		child: CircularProgressIndicator(
																			strokeWidth: 2.6,
																			valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
																		),
																	),
																	const SizedBox(height: 10),
																	Text(
																		AppLocalizations.of(context)?.camera_processing ?? 'Processing camera...',
																		style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
																	),
																],
															),
														),
													),
											],
										),
									);
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
									color: Colors.white.withValues(alpha: 0.9),
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
										color: Colors.white.withValues(alpha: 0.9),
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
									boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4.h))],
								),
								child: Text(
									AppLocalizations.of(context)?.detection_sample ?? 'There is a laptop one meter in front of you',
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
									boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: Offset(0, 4.h))],
								),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										// Camera button - Toggle camera on/off
										BlocBuilder<CameraCubit, dynamic>(
											builder: (context, camState) {
												final cubit = context.read<CameraCubit>();
												final cameraActive = (camState is CameraState) ? camState.cameraActive : false;
												final cameraBusy = (camState is CameraState) ? camState.cameraBusy : false;
												return Tooltip(
													message: cameraBusy
															? (AppLocalizations.of(context)?.camera_processing ?? 'Processing camera...')
															: (cameraActive
																	? (AppLocalizations.of(context)?.camera_turn_off ?? 'Turn off camera')
																	: (AppLocalizations.of(context)?.camera_turn_on ?? 'Turn on camera')),
													child: IconButton(
														onPressed: cameraBusy ? null : () => cubit.toggleCamera(),
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
													message: micActive
															? (AppLocalizations.of(context)?.mic_turn_off ?? 'Turn off microphone')
															: (AppLocalizations.of(context)?.mic_turn_on ?? 'Turn on microphone'),
													child: GestureDetector(
														onTap: () => cubit.toggleMicrophone(),
														child: Container(
															width: AppSizes.buttonWidth,
															height: AppSizes.buttonHeight,
															decoration: BoxDecoration(
																color: micActive ? AppColors.primary : Colors.grey[300],
																shape: BoxShape.circle,
																boxShadow: [BoxShadow(color: (micActive ? AppColors.primary : Colors.grey).withValues(alpha: 0.4), blurRadius: 16, offset: Offset(0, 6.h))],
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
													message: cameraActive
															? (AppLocalizations.of(context)?.camera_health_check ?? 'Check camera health')
															: (AppLocalizations.of(context)?.camera_health_check_enable_hint ?? 'Turn on camera to check health'),
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
