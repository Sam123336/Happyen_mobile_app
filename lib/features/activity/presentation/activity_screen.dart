import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/data/demo_images.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';

/// "Activity — Social & Event Pulse".
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const _tabs = <String>['ALL', 'SOCIAL', 'EVENTS'];

  int _tab = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepInk,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              top: headerOffset(context, 80),
              bottom: 100,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 68,
                      child: ListView.separated(
                        itemBuilder: (context, index) => Center(
                          child: _ActivityTab(
                            index: index,
                            label: _tabs[index],
                            onTap: () => setState(() => _tab = index),
                            selected: index == _tab,
                          ),
                        ),
                        itemCount: _tabs.length,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _DayLabel('TODAY'),
                    const SizedBox(height: 24),
                    _ActivityCard(
                      badgeColor: AppColors.secondary,
                      badgeIcon: Icons.favorite,
                      badgeIconColor: AppColors.onSecondary,
                      imageIndex: 1,
                      thumbnailIndex: 2,
                      time: '2h ago',
                      title: TextSpan(
                        children: [
                          TextSpan(
                            style: AppText.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.375,
                            ),
                            text: 'Sarah K.',
                          ),
                          TextSpan(
                            style: AppText.bodyMd.copyWith(height: 1.375),
                            text: ' liked your photo from ',
                          ),
                          TextSpan(
                            style: AppText.bodyMd.copyWith(
                              color: AppColors.tertiary,
                              height: 1.375,
                            ),
                            text: 'The Vault',
                          ),
                          TextSpan(
                            style: AppText.bodyMd.copyWith(height: 1.375),
                            text: '.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ActivityCard(
                      badgeColor: AppColors.primaryFixed,
                      badgeIcon: Icons.chat_bubble,
                      badgeIconColor: AppColors.onPrimaryFixed,
                      imageIndex: 3,
                      time: '4h ago',
                      title: TextSpan(
                        children: [
                          TextSpan(
                            style: AppText.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.375,
                            ),
                            text: 'Alex M.',
                          ),
                          TextSpan(
                            style: AppText.bodyMd.copyWith(height: 1.375),
                            text:
                                ' commented: "Lost in the bassline. The '
                                'energy here is unmatched..."',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _VerifiedActivityCard(),
                    const SizedBox(height: 48),
                    const _DayLabel('YESTERDAY'),
                    const SizedBox(height: 24),
                    _ActivityCard(
                      badgeColor: AppColors.surfaceTint,
                      badgeIcon: Icons.person_add,
                      badgeIconColor: AppColors.deepInk,
                      imageIndex: 4,
                      time: '1d ago',
                      title: TextSpan(
                        children: [
                          TextSpan(
                            style: AppText.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.375,
                            ),
                            text: 'Elena R.',
                          ),
                          TextSpan(
                            style: AppText.bodyMd.copyWith(height: 1.375),
                            text: ' started following you.',
                          ),
                        ],
                      ),
                      trailing: const _FollowBackButton(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(left: 0, right: 0, top: 0, child: _ActivityHeader()),
        ],
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader();

  @override
  Widget build(BuildContext context) {
    return Frosted(
      blur: 24,
      color: AppColors.surface.withValues(alpha: 0.4),
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      height: 40,
                      width: 40,
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.onSurface,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Activity',
                    style: AppText.headlineMd.copyWith(
                      letterSpacing: -0.025 * 24,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                  shape: BoxShape.circle,
                ),
                height: 40,
                width: 40,
                child: ClipOval(child: NetImage(DemoImages.activity[0])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({
    required this.index,
    required this.label,
    required this.onTap,
    required this.selected,
  });

  final int index;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final base = index == 0
        ? AppColors.surfaceContainerHigh
        : AppColors.surfaceContainer;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? AppColors.tertiary.withValues(alpha: 0.3)
                : AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: selected
              ? [
                  BoxShadow(
                    blurRadius: 20,
                    color: AppColors.tertiary.withValues(alpha: 0.15),
                  ),
                ]
              : null,
          color: selected ? AppColors.tertiary.withValues(alpha: 0.1) : base,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Text(
          label,
          style: AppText.labelMd.copyWith(
            color: selected
                ? AppColors.tertiary
                : (index == 0
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant),
            letterSpacing: 0.1 * 14,
          ),
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppText.labelSm.copyWith(
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.1 * 12,
      ),
    );
  }
}

/// `.glass-card`: rgba(42,42,38,.4) + blur(12) + 1px rgba(144,144,149,.1).
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.glow = false});

  final Widget child;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final card = Frosted(
      blur: 12,
      border: Border.all(
        color: glow
            ? AppColors.tertiary.withValues(alpha: 0.3)
            : AppColors.outline.withValues(alpha: 0.1),
      ),
      borderRadius: BorderRadius.circular(24),
      color: const Color(0x662A2A26),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
    if (!glow) return card;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: AppColors.tertiary.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: card,
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.badgeColor,
    required this.badgeIcon,
    required this.badgeIconColor,
    required this.imageIndex,
    required this.time,
    required this.title,
    this.thumbnailIndex,
    this.trailing,
  });

  final Color badgeColor;
  final IconData badgeIcon;
  final Color badgeIconColor;
  final int imageIndex;
  final int? thumbnailIndex;
  final String time;
  final TextSpan title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        crossAxisAlignment: trailing == null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          _AvatarWithBadge(
            badgeColor: badgeColor,
            badgeIcon: badgeIcon,
            badgeIconColor: badgeIconColor,
            imageIndex: imageIndex,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(title),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppText.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (thumbnailIndex != null) ...[
            const SizedBox(width: 16),
            Opacity(
              opacity: 0.8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: SizedBox(
                  height: 56,
                  width: 56,
                  child: NetImage(DemoImages.activity[thumbnailIndex!]),
                ),
              ),
            ),
          ],
          if (trailing != null) ...[const SizedBox(width: 16), trailing!],
        ],
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge({
    required this.badgeColor,
    required this.badgeIcon,
    required this.badgeIconColor,
    required this.imageIndex,
  });

  final Color badgeColor;
  final IconData badgeIcon;
  final Color badgeIconColor;
  final int imageIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: 52,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
              shape: BoxShape.circle,
            ),
            height: 48,
            width: 48,
            child: ClipOval(child: NetImage(DemoImages.activity[imageIndex])),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.deepInk, width: 2),
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              height: 24,
              width: 24,
              child: Icon(badgeIcon, color: badgeIconColor, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedActivityCard extends StatelessWidget {
  const _VerifiedActivityCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      glow: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.4),
              ),
              color: AppColors.tertiary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            height: 48,
            width: 48,
            child: const Icon(
              Icons.verified,
              color: AppColors.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: AppColors.warmPaper,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    'VERIFIED HERE',
                    style: AppText.labelSm.copyWith(
                      color: AppColors.deepInk,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.05 * 10,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        style: AppText.bodyMd.copyWith(height: 1.375),
                        text: 'Your check-in at ',
                      ),
                      TextSpan(
                        style: AppText.bodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.375,
                        ),
                        text: 'Neon Gardens',
                      ),
                      TextSpan(
                        style: AppText.bodyMd.copyWith(height: 1.375),
                        text: ' has been verified by the venue.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '5h ago',
                  style: AppText.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowBackButton extends StatelessWidget {
  const _FollowBackButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.tertiary),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'FOLLOW BACK',
        style: AppText.labelSm.copyWith(
          color: AppColors.tertiary,
          letterSpacing: 0.1 * 12,
        ),
      ),
    );
  }
}
