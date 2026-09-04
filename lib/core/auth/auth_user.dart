class AuthUser {
  const AuthUser({
    required this.id,
    required this.emailVerified,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoUrl,
  });

  final String id;
  final String? displayName;
  final String? email;
  final bool emailVerified;
  final String? phoneNumber;
  final String? photoUrl;
}
