enum PrivacyAudience { nobody, friends, everyone }

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.emailVerified,
    required this.momentsVisibility,
    required this.presenceVisibility,
    required this.profileVisibility,
    required this.status,
    required this.userId,
    this.avatarUrl,
    this.bio,
    this.email,
    this.phoneE164,
    this.username,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    avatarUrl: json['avatarUrl'] as String?,
    bio: json['bio'] as String?,
    displayName: json['displayName'] as String,
    email: json['email'] as String?,
    emailVerified: json['emailVerified'] as bool,
    momentsVisibility: PrivacyAudience.values.byName(
      json['momentsVisibility'] as String,
    ),
    phoneE164: json['phoneE164'] as String?,
    presenceVisibility: PrivacyAudience.values.byName(
      json['presenceVisibility'] as String,
    ),
    profileVisibility: PrivacyAudience.values.byName(
      json['profileVisibility'] as String,
    ),
    status: json['status'] as String,
    userId: json['userId'] as String,
    username: json['username'] as String?,
  );

  final String? avatarUrl;
  final String? bio;
  final String displayName;
  final String? email;
  final bool emailVerified;
  final PrivacyAudience momentsVisibility;
  final String? phoneE164;
  final PrivacyAudience presenceVisibility;
  final PrivacyAudience profileVisibility;
  final String status;
  final String userId;
  final String? username;
}
