import 'package:bdaya_repository_pattern/src/disposable.dart';

/// the CacheService should implment this interface in a production app
abstract class CacheServiceInterface with DisposableMixin {
  /// Register all type adapters needed by hive
  void registerTypeAdapters();

  /// Initialize repositories, DO NOT CALL THIS DIRECTLY, INSTEAD CALL [init]
  Future<void> initRepos();

  Future<void> init() async {
    registerTypeAdapters();
    await initRepos();
  }

  @override
  Future<void> dispose() async {}
}
