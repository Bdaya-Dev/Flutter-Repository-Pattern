/// the CacheService should implment this interface in a production app
abstract class CacheServiceInterface {
  /// Register all type adapters needed by hive
  void registerTypeAdapters();

  /// Initialize repositories
  Future<void> initRepos();
}
