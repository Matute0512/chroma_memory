/// Constantes globales de la aplicación.
abstract final class AppConstants {
  /// Nombre comercial que se muestra en la UI y en launcher.
  static const String appName = 'Chroma Memory';

  /// Versión visible. Mantener sincronizada con `version:` de pubspec.yaml.
  static const String appVersion = '1.0.0';

  /// applicationId / namespace de Android (android/app/build.gradle.kts).
  static const String androidApplicationId = 'dev.matute.chroma_memory';

  /// Tag usado por el logger (core/utils/logger.dart) cuando exista.
  static const String logTag = 'chroma_memory';
}
