import 'package:happyn_mobile/flavor.dart';
import 'package:happyn_mobile/main.dart';

/// `flutter run --flavor uat -t lib/main_uat.dart`
Future<void> main() => bootstrap(Flavor.uat);
