
enum AppFlavor { global, ethiopia }

class AppConfig {
  static final String _raw =
      const String.fromEnvironment('APP_FLAVOR', defaultValue: 'global');

  static AppFlavor get flavor =>
      _raw.toLowerCase() == 'ethiopia' ? AppFlavor.ethiopia : AppFlavor.global;

  static bool get isLocalService => flavor == AppFlavor.ethiopia;
}
