import 'package:shared_preferences/shared_preferences.dart';

/// Fuente de datos local del Modo Clásico (shared_preferences).
///
/// El MVP guarda solo el mejor puntaje. Cuando se migre a Hive, este es el
/// punto único a reemplazar.
class ClassicLocalDataSource {
  const ClassicLocalDataSource();

  static const String _kBestScore = 'classic_mode.best_score';

  Future<int> readBestScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kBestScore) ?? 0;
  }

  Future<void> writeBestScore(int score) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBestScore, score);
  }
}
