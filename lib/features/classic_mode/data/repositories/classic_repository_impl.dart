import '../datasources/classic_local_datasource.dart';
import '../../domain/repositories/i_classic_repository.dart';

/// Implementación del repositorio de un modo de secuencias sobre la fuente
/// local (récord propio + último reto completado).
class ClassicRepositoryImpl implements IClassicRepository {
  const ClassicRepositoryImpl(this._dataSource);

  final ClassicLocalDataSource _dataSource;

  @override
  Future<int> getBestScore() => _dataSource.readBestScore();

  @override
  Future<void> saveBestScore(int score) => _dataSource.writeBestScore(score);

  @override
  Future<String?> lastCompleted() => _dataSource.readLastCompleted();

  @override
  Future<void> markCompleted(String key) =>
      _dataSource.writeLastCompleted(key);
}
