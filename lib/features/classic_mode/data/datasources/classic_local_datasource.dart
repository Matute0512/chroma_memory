import 'package:shared_preferences/shared_preferences.dart';

/// Fuente de datos local de un modo de secuencias (shared_preferences).
///
/// Guarda el mejor puntaje bajo un [prefix] por modo (classic_mode, zen_mode,
/// daily_mode) para que cada modo tenga su propio récord. También guarda el
/// último reto completado (lo usa el Desafío Diario). Cuando se migre a Hive,
/// este es el punto único a reemplazar.
class ClassicLocalDataSource {
  const ClassicLocalDataSource({this.prefix = 'classic_mode'});

  final String prefix;

  String get _bestKey => '$prefix.best_score';
  String get _completedKey => '$prefix.last_completed';

  Future<int> readBestScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestKey) ?? 0;
  }

  Future<void> writeBestScore(int score) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestKey, score);
  }

  Future<String?> readLastCompleted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_completedKey);
  }

  Future<void> writeLastCompleted(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completedKey, key);
  }
}
