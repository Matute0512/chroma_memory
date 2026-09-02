/// Contrato de datos del Modo Clásico.
///
/// Por ahora solo persiste el mejor puntaje; la generación/validación de
/// secuencias viven en los casos de uso (no son persistencia).
abstract interface class IClassicRepository {
  /// Mejor puntaje histórico (0 si todavía no hay).
  Future<int> getBestScore();

  /// Guarda un nuevo mejor puntaje.
  Future<void> saveBestScore(int score);
}
