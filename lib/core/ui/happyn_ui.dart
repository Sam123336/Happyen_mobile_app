import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/theme/app_theme.dart';

/// Network image with the dark placeholder the Stitch mocks sit on.
class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key, this.fit = BoxFit.cover});

  final BoxFit fit;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) =>
          const ColoredBox(color: AppColors.surfaceContainer),
      frameBuilder: (context, child, frame, wasSyncLoaded) {
        if (wasSyncLoaded || frame != null) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1,
            child: child,
          );
        }
        return const ColoredBox(color: AppColors.surfaceContainer);
      },
    );
  }
}

/// `backdrop-blur-*` + translucent fill.
class Frosted extends StatelessWidget {
  const Frosted({
    required this.child,
    super.key,
    this.blur = 16,
    this.borderRadius = BorderRadius.zero,
    this.color = const Color(0x6620201C),
    this.border,
  });

  final double blur;
  final BoxBorder? border;
  final BorderRadius borderRadius;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: border,
            borderRadius: borderRadius,
            color: color,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The Stitch screens are laid out without system insets, so design-space top
/// offsets need the status bar height added on a real device.
double headerOffset(BuildContext context, double designTop) =>
    designTop + MediaQuery.paddingOf(context).top;

/// Bottom inset for the navigation bar, keeping the design's 32px as a floor.
double navInset(BuildContext context) =>
    math.max(32, MediaQuery.viewPaddingOf(context).bottom);

enum HappynTab { city, discover, people }

/// `rounded-t-xl backdrop-blur-2xl bg-surface-container-lowest/80` nav bar.
class HappynBottomNav extends StatelessWidget {
  const HappynBottomNav({
    required this.current,
    required this.onChanged,
    super.key,
    this.compactLabels = false,
    this.discoverIcon = Icons.search,
    this.discoverLabel = 'DISCOVER',
    this.peopleIcon = Icons.group,
  });

  /// The profile design renders the nav labels at 10px instead of 14px.
  final bool compactLabels;
  final HappynTab current;
  final IconData discoverIcon;
  final String discoverLabel;
  final ValueChanged<HappynTab> onChanged;
  final IconData peopleIcon;

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 24,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
      border: Border(
        top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          16,
          AppSpacing.marginMobile,
          navInset(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              active: current == HappynTab.city,
              activeIcon: Icons.explore,
              compact: compactLabels,
              icon: Icons.explore_outlined,
              label: 'CITY',
              onTap: () => onChanged(HappynTab.city),
            ),
            _NavItem(
              active: current == HappynTab.discover,
              activeIcon: discoverIcon,
              compact: compactLabels,
              icon: discoverIcon,
              label: discoverLabel,
              onTap: () => onChanged(HappynTab.discover),
            ),
            _NavItem(
              active: current == HappynTab.people,
              activeIcon: peopleIcon,
              compact: compactLabels,
              icon: peopleIcon == Icons.group
                  ? Icons.group_outlined
                  : peopleIcon,
              label: 'PEOPLE',
              onTap: () => onChanged(HappynTab.people),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.active,
    required this.activeIcon,
    required this.compact,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final IconData activeIcon;
  final bool compact;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.secondary : AppColors.onSurfaceVariant;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        scale: active ? 1.1 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: compact
                  ? AppText.labelSm.copyWith(
                      color: color,
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      height: 15 / 10,
                      letterSpacing: 0.05 * 10,
                    )
                  : AppText.labelMd.copyWith(
                      color: color,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lime "N° Energy" / "High Vibe" pill.
class EnergyPill extends StatelessWidget {
  const EnergyPill({
    required this.label,
    super.key,
    this.background,
    this.border,
    this.iconSize = 16,
    this.style,
  }) : bare = false;

  /// Icon + text with no pill behind it.
  const EnergyPill.bare({
    required this.label,
    super.key,
    this.iconSize = 16,
    this.style,
  }) : background = null,
       bare = true,
       border = null;

  final bool bare;
  final Color? background;
  final BoxBorder? border;
  final double iconSize;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: bare
          ? null
          : BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(AppRadius.full),
              color:
                  background ??
                  AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
            ),
      padding: bare
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppColors.tertiary,
            size: iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: (style ?? AppText.labelSm).copyWith(
              color: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Warm-paper "Verified Here" / "Editor's Pick" chip.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    required this.label,
    super.key,
    this.border,
    this.iconSize = 14,
  });

  final BoxBorder? border;
  final double iconSize;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Color(0x40000000),
            offset: Offset(0, 2),
          ),
        ],
        color: AppColors.warmPaper,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: AppColors.deepInk, size: iconSize),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppText.labelSm.copyWith(
              color: AppColors.deepInk,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.05 * 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlapping avatar row with a trailing `+N` bubble.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    required this.urls,
    super.key,
    this.borderColor = AppColors.background,
    this.borderWidth = 2,
    this.overlap = 12,
    this.overflowLabel,
    this.size = 32,
  });

  final Color borderColor;
  final double borderWidth;
  final double overlap;
  final String? overflowLabel;
  final double size;
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (final url in urls)
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth),
            shape: BoxShape.circle,
          ),
          height: size,
          width: size,
          child: ClipOval(child: NetImage(url)),
        ),
      if (overflowLabel != null)
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth),
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          height: size,
          width: size,
          child: Text(
            overflowLabel!,
            style: AppText.labelSm.copyWith(fontSize: size <= 24 ? 10 : 12),
          ),
        ),
    ];
    return SizedBox(
      height: size,
      width: items.isEmpty ? 0 : size + (items.length - 1) * (size - overlap),
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(left: i * (size - overlap), child: items[i]),
        ],
      ),
    );
  }
}

/// A ring of satellites rotating around a hub, with each satellite
/// counter-rotated so it stays upright — the design's "Orbit" motif.
class OrbitRing extends StatefulWidget {
  const OrbitRing({
    required this.diameter,
    required this.satellites,
    super.key,
    this.dashed = false,
    this.duration = const Duration(seconds: 40),
    this.reverse = false,
    this.ringColor,
  });

  final bool dashed;
  final double diameter;
  final Duration duration;
  final bool reverse;
  final Color? ringColor;

  /// Angle in turns (0..1) measured clockwise from the top, plus the widget.
  final List<(double, Widget)> satellites;

  @override
  State<OrbitRing> createState() => _OrbitRingState();
}

class _OrbitRingState extends State<OrbitRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.diameter / 2;
    return SizedBox(
      height: widget.diameter,
      width: widget.diameter,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final spin =
              _controller.value * (widget.reverse ? -1 : 1) * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.ringColor != null)
                CustomPaint(
                  painter: _RingPainter(
                    color: widget.ringColor!,
                    dashed: widget.dashed,
                  ),
                  size: Size.square(widget.diameter),
                ),
              for (final (turns, child) in widget.satellites)
                Builder(
                  builder: (context) {
                    final angle = spin + turns * 2 * math.pi - math.pi / 2;
                    return Transform.translate(
                      offset: Offset(
                        radius * math.cos(angle),
                        radius * math.sin(angle),
                      ),
                      child: Transform.rotate(angle: -spin, child: child),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    if (!dashed) {
      canvas.drawCircle(center, radius, paint);
      return;
    }
    const dash = 0.03;
    for (var t = 0.0; t < 1; t += dash * 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        t * 2 * math.pi,
        dash * 2 * math.pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashed != dashed;
}

/// Slow opacity pulse used on energy indicators.
class PulseSlow extends StatefulWidget {
  const PulseSlow({
    required this.child,
    super.key,
    this.duration = const Duration(seconds: 3),
    this.minOpacity = 0.7,
  });

  final Widget child;
  final Duration duration;
  final double minOpacity;

  @override
  State<PulseSlow> createState() => _PulseSlowState();
}

class _PulseSlowState extends State<PulseSlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 1,
        end: widget.minOpacity,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// Pill button used for the category / vibe filter rows.
class FilterPill extends StatelessWidget {
  const FilterPill({
    required this.label,
    required this.selected,
    super.key,
    this.onTap,
    this.selectedColor = AppColors.secondary,
    this.selectedTextColor = AppColors.onSecondaryContainer,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final Color selectedColor;
  final Color selectedTextColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          border: selected ? null : Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: selected
              ? [
                  BoxShadow(
                    blurRadius: 0,
                    color: selectedColor.withValues(alpha: 0.2),
                    spreadRadius: 2,
                  ),
                ]
              : null,
          color: selected ? selectedColor : AppColors.surfaceContainerHigh,
        ),
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: AppText.labelMd.copyWith(
            color: selected ? selectedTextColor : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
