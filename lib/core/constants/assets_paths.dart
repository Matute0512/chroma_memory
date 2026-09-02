/// Rutas raíz de los assets declarados en pubspec.yaml.
///
/// Los subdirectorios ya existen en disco (assets/fonts, assets/images,
/// assets/sounds, assets/textures) pero todavía están vacíos. A medida que se
/// agreguen archivos hay que declararlos en la sección `flutter:` de
/// pubspec.yaml para que Flutter los empaquete.
abstract final class AssetsPaths {
  static const String images = 'assets/images/';
  static const String fonts = 'assets/fonts/';
  static const String sounds = 'assets/sounds/';
  static const String textures = 'assets/textures/';
}
