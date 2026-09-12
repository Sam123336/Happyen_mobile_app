import 'package:flutter/material.dart';

import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/core/ui/happyn_ui.dart';
import 'package:happyn_mobile/features/profile/domain/user_profile.dart';

/// The account's picture, its initials when it has none, and an outline when
/// nobody is signed in. Never a stock photo.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.profile, required this.size, super.key});

  final UserProfile? profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = profile?.avatarUrl;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        color: AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      height: size,
      width: size,
      child: ClipOval(
        child: url != null
            ? NetImage(url)
            : profile != null
            ? Text(
                initialsOf(profile!.displayName),
                style: AppText.labelMd.copyWith(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w700,
                ),
              )
            : Icon(
                Icons.person_outline,
                color: AppColors.onSurfaceVariant,
                size: size * 0.55,
              ),
      ),
    );
  }
}

/// "Sam Coder" → "SC", "sam" → "S".
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}
