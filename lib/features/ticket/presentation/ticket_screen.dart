import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';

/// "Ticket — Your Entry to the City".
class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepInk,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              top: headerOffset(context, 96),
              bottom: 128,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                child: _GlassPanel(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 192,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NetImage(DemoImages.ticket[0]),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.surfaceContainer,
                                    Color(0x0020201C),
                                  ],
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            const Positioned(
                              right: 16,
                              top: 16,
                              child: VerifiedBadge(
                                iconSize: 16,
                                label: 'Verified Access',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -24),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: _TicketBody(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(left: 0, right: 0, top: 0, child: _TicketHeader()),
        ],
      ),
    );
  }
}

class _TicketHeader extends StatelessWidget {
  const _TicketHeader();

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 24,
      color: AppColors.primaryContainer.withValues(alpha: 0.4),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: _GlassPanel(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: const SizedBox(
                    height: 48,
                    width: 48,
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Text(
                'Your Pass',
                style: AppText.headlineSm.copyWith(letterSpacing: -0.025 * 20),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.glass-panel`: rgba(32,32,28,.4) + blur(16) + 1px rgba(144,144,149,.1).
class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.borderRadius = BorderRadius.zero,
  });

  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Frosted(
      border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      borderRadius: borderRadius,
      color: const Color(0x6620201C),
      child: child,
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Neon Nights', style: AppText.displayLg),
        const SizedBox(height: 8),
        Text(
          '@ The Vault',
          style: AppText.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        const _DetailRow(
          leadingLabel: 'DATE',
          leadingValue: 'Oct 24, 2024',
          trailingLabel: 'TIME',
          trailingValue: '11:00 PM',
        ),
        const SizedBox(height: 16),
        const _DetailRow(
          leadingHighlighted: true,
          leadingLabel: 'TICKET TYPE',
          leadingValue: 'VIP All Access',
          trailingLabel: 'ORDER',
          trailingValue: '#NN-8492',
        ),
        const SizedBox(height: 32),
        const _QrPanel(),
        const SizedBox(height: 24),
        const _WalletButton(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.leadingLabel,
    required this.leadingValue,
    required this.trailingLabel,
    required this.trailingValue,
    this.leadingHighlighted = false,
  });

  final bool leadingHighlighted;
  final String leadingLabel;
  final String leadingValue;
  final String trailingLabel;
  final String trailingValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _DetailCell(
            highlighted: leadingHighlighted,
            label: leadingLabel,
            value: leadingValue,
          ),
          _DetailCell(
            alignment: CrossAxisAlignment.end,
            label: trailingLabel,
            value: trailingValue,
          ),
        ],
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
    this.highlighted = false,
  });

  final CrossAxisAlignment alignment;
  final bool highlighted;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppText.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.1 * 12,
          ),
        ),
        Text(
          value,
          style: AppText.headlineSm.copyWith(
            color: highlighted ? AppColors.secondary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _QrPanel extends StatelessWidget {
  const _QrPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            color: AppColors.secondary.withValues(alpha: 0.3),
          ),
        ],
        color: AppColors.surfaceContainerLow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              color: AppColors.secondary.withValues(alpha: 0.1),
              height: 192,
              width: 192,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Opacity(
                    opacity: 0.8,
                    child: CustomPaint(
                      painter: _QrDotsPainter(),
                      size: Size.square(192),
                    ),
                  ),
                  for (final corner in const [
                    Alignment.topLeft,
                    Alignment.topRight,
                    Alignment.bottomLeft,
                  ])
                    Align(
                      alignment: corner,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        height: 40,
                        margin: const EdgeInsets.all(8),
                        width: 40,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15,
                          color: AppColors.secondary.withValues(alpha: 0.5),
                        ),
                      ],
                      color: AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: AppColors.secondary,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan at the door',
            style: AppText.labelSm.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// `radial-gradient(#ffb4a7 2px, transparent 2px)` on a 10px grid.
class _QrDotsPainter extends CustomPainter {
  const _QrDotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.secondary;
    for (var y = 5.0; y < size.height; y += 10) {
      for (var x = 5.0; x < size.width; x += 10) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_QrDotsPainter oldDelegate) => false;
}

class _WalletButton extends StatelessWidget {
  const _WalletButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: AppColors.secondary.withValues(alpha: 0.2),
          ),
        ],
        color: AppColors.secondary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: AppColors.onSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'ADD TO WALLET',
            style: AppText.labelMd.copyWith(
              color: AppColors.onSecondary,
              letterSpacing: 0.1 * 14,
            ),
          ),
        ],
      ),
    );
  }
}
