import '../datasources/classic_local_datasource.dart';
import '../../domain/repositories/i_classic_repository.dart';

/// Implementación del repositorio del Modo Clásico sobre la fuente local.
class ClassicRepositoryImpl implements IClassicRepository {
  const ClassicRepositoryImpl(this._dataSource);

  final ClassicLocalDataSource _dataSource;

  @override
  Future<int> getBestScore() => _dataSource.readBestScore();

  @override
  Future<void> saveBestScore(int score) => _dataSource.writeBestScore(score);
}
