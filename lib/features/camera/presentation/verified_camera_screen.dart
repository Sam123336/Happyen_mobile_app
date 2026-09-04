import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';

/// "Verified Camera — Live at Event".
class VerifiedCameraScreen extends StatefulWidget {
  const VerifiedCameraScreen({super.key});

  @override
  State<VerifiedCameraScreen> createState() => _VerifiedCameraScreenState();
}

class _VerifiedCameraScreenState extends State<VerifiedCameraScreen> {
  static const _modes = <String>['PHOTO', 'VIDEO', 'MOMENT'];

  int _mode = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepInk,
      body: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(DemoImages.camera[0]),
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SizedBox(
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    colors: [Color(0xCC0B0D12), Color(0x000B0D12)],
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    colors: [Color(0xE60B0D12), Color(0x000B0D12)],
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        Text(
                          'Neon Nights Block Party',
                          style: AppText.headlineSm,
                        ),
                        const SizedBox(height: 8),
                        const VerifiedBadge(
                          iconSize: 14,
                          label: 'VERIFIED LOCATION',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < _modes.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 24),
                                  _ModeLabel(
                                    active: i == _mode,
                                    label: _modes[i],
                                    onTap: () => setState(() => _mode = i),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 32),
                            const _CaptureButton(),
                            const SizedBox(height: 16),
                            Text(
                              'HOLD TO CAPTURE',
                              style: AppText.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.05 * 12,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: _RoundGlassButton(
                            icon: Icons.close,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: _RoundGlassButton(icon: Icons.flip_camera_ios),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppText.labelMd.copyWith(
              color: active ? AppColors.secondary : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            decoration: BoxDecoration(
              color: active ? AppColors.secondary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            height: 4,
            width: 4,
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatefulWidget {
  const _CaptureButton();

  @override
  State<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapCancel: () => setState(() => _pressed = false),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _pressed ? 0.95 : 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondary, width: 4),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                color: AppColors.secondary.withValues(alpha: 0.4),
              ),
            ],
            shape: BoxShape.circle,
          ),
          height: 80,
          width: 80,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: _pressed ? 0.9 : 1,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              height: 64,
              width: 64,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundGlassButton extends StatelessWidget {
  const _RoundGlassButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Frosted(
        blur: 12,
        borderRadius: BorderRadius.circular(AppRadius.full),
        color: AppColors.surfaceContainer.withValues(alpha: 0.5),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, color: AppColors.onSurface, size: 24),
        ),
      ),
    );
  }
}
