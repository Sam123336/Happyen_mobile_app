import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/camera/presentation/verified_camera_screen.dart';

/// "Geofence Entry — You're Here": arrival confirmation with a radar pulse.
class GeofenceScreen extends StatelessWidget {
  const GeofenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 0.3,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Transform.scale(
                      scale: 1.1,
                      child: NetImage(DemoImages.geofence[0]),
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      colors: [
                        Color(0x66131410),
                        Color(0x99131410),
                        Color(0xE6131410),
                      ],
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: Center(child: _RadarPulse())),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                  vertical: AppSpacing.marginDesktop,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox.shrink(),
                    const _ArrivalCopy(),
                    const _CaptureCallToAction(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three expanding rings on a 3s stagger, matching `@keyframes radar-pulse`.
class _RadarPulse extends StatefulWidget {
  const _RadarPulse();

  @override
  State<_RadarPulse> createState() => _RadarPulseState();
}

class _RadarPulseState extends State<_RadarPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      width: 128,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Builder(
                  builder: (context) {
                    final t = (_controller.value + i / 3) % 1;
                    return Opacity(
                      opacity: (0.8 * (1 - t)).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.1 + t * 3.9,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.secondary,
                              width: 8 - t * 7,
                            ),
                            shape: BoxShape.circle,
                          ),
                          height: 128,
                          width: 128,
                        ),
                      ),
                    );
                  },
                ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: AppColors.secondary.withValues(alpha: 0.8),
                    ),
                  ],
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                height: 16,
                width: 16,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArrivalCopy extends StatelessWidget {
  const _ArrivalCopy();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0x26FFB4A7), Color(0x000B0D12)],
          stops: [0, 0.7],
        ),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "YOU'RE HERE",
              style: AppText.displayXl.copyWith(letterSpacing: -0.05 * 52),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.tertiary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'LOCATION VERIFIED',
                  style: AppText.labelSm.copyWith(
                    color: AppColors.tertiary,
                    letterSpacing: 0.1 * 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Bangalore Comedy Night',
              style: AppText.headlineMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.group,
                      color: AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '428 live',
                      style: AppText.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.outlineVariant,
                    shape: BoxShape.circle,
                  ),
                  height: 4,
                  width: 4,
                ),
                const SizedBox(width: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 32,
                      child: Stack(
                        children: [
                          for (var i = 0; i < 2; i++)
                            Positioned(
                              left: i * 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.background,
                                  ),
                                  color: i == 0
                                      ? AppColors.surfaceVariant
                                      : AppColors.outlineVariant,
                                  shape: BoxShape.circle,
                                ),
                                height: 20,
                                width: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '3 friends',
                      style: AppText.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureCallToAction extends StatelessWidget {
  const _CaptureCallToAction();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Capture a Moment',
              style: AppText.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const VerifiedCameraScreen(),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30,
                      color: AppColors.secondary.withValues(alpha: 0.15),
                    ),
                  ],
                  color: AppColors.secondary.withValues(alpha: 0.1),
                ),
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'HOLD TO CAPTURE',
                      style: AppText.labelMd.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 0.1 * 14,
                      ),
                    ),
                    Positioned(
                      right: 24,
                      child: Icon(
                        Icons.fingerprint,
                        color: AppColors.secondary.withValues(alpha: 0.5),
                        size: 24,
                      ),
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
