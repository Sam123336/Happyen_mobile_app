/// Which build this is. Dev and prod differ only in where they point and what
/// they are called; there is no behavioural branching beyond that.
enum Flavor { dev, prod }

/// Overrides the flavor's own default, so one build can be aimed at a laptop or
/// a preview deployment without a second flavor:
/// `--dart-define=HAPPYN_API_ORIGIN=http://192.168.1.10:3000`.
const _apiOriginOverride = String.fromEnvironment('HAPPYN_API_ORIGIN');

/// Supabase project credentials, supplied at build time:
/// `--dart-define=SUPABASE_URL=https://xxxx.supabase.co
///  --dart-define=SUPABASE_ANON_KEY=eyJ...`.
///
/// The anon key is a publishable client key, not a secret — it only ever
/// grants what the project's policies allow. The service-role key must never
/// reach the app.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// Without both, sign-in is unavailable and the app stays in its map-only
/// shell rather than failing to launch.
bool get hasSupabaseConfig =>
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

class AppConfig {
  const AppConfig({required this.apiOrigin, required this.flavor});

  factory AppConfig.of(Flavor flavor) => AppConfig(
    apiOrigin: _apiOriginOverride.isNotEmpty
        ? _apiOriginOverride
        : switch (flavor) {
            // An emulator reaches the host at 10.0.2.2 and a simulator at
            // localhost; pass HAPPYN_API_ORIGIN when neither is what you want.
            Flavor.dev => 'http://localhost:3000',
            // Vercel's stable alias for main. Replace with a custom domain
            // when one exists.
            Flavor.prod =>
              'https://happyen-backend-git-main-sams-projects-83758424.vercel.app',
          },
    flavor: flavor,
  );

  final String apiOrigin;
  final Flavor flavor;

  bool get isDev => flavor == Flavor.dev;

  /// Shown in the app switcher; the launcher name comes from the platform.
  String get appName => isDev ? 'Happyen Dev' : 'Happyen';
}
