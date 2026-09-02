import 'package:shared_preferences/shared_preferences.dart';

/// Fuente de datos local de un modo de secuencias (shared_preferences).
///
/// Guarda el mejor puntaje bajo un [prefix] por modo (classic_mode, zen_mode,
/// daily_mode) para que cada modo tenga su propio récord. Cuando se migre a
/// Hive, este es el punto único a reemplazar.
class ClassicLocalDataSource {
  const ClassicLocalDataSource({this.prefix = 'classic_mode'});

  final String prefix;

  String get _bestKey => '$prefix.best_score';

  Future<int> readBestScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestKey) ?? 0;
  }

  Future<void> writeBestScore(int score) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestKey, score);
  }
}
