import 'package:bdaya_repository_pattern/src/disposable.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:hive/hive.dart';

abstract class Repo<TKey, TVal> with DisposableMixin {
  /// The name of the box.
  String get boxName;

  /// Initializes the repository.
  ///
  /// should be called during splash screen (before any data can be fetched)
  Future<void> init();

  /// Updates the value at the given [key] to [newValue].
  Future<void> put(TKey key, TVal newValue) async {
    await putAll({key: newValue});
  }

  /// get the existing keys as a Set of unique values
  Set<TKey> get keySet => keys.toSet();

  /// get the first key, or null if the box is empty
  TKey? get firstOrNullKey => keys.firstWhereOrNull((element) => true);

  /// All the keys in the box.
  ///
  /// The keys are sorted alphabetically in ascending order.
  Iterable<TKey> get keys;

  /// watch the dataBox for changes to a specific key, use [dataStreamFor] instead
  Stream<BoxEvent> watch({TKey? key});

  /// watch for multiple keys, the result map will only contain (key,value) pairs that are NOT deleted
  Stream<Map<TKey, TVal>> dataStreamFor(Iterable<TKey> keys);

  /// a stream that tracks [keys] when it changes
  Stream<Iterable<TKey>> get keyStream async* {
    yield keys;
    yield* watch().map((value) => keys);
  }

  /// a stream that tracks [keySet] when it changes
  Stream<Set<TKey>> get keySetStream async* {
    yield keySet;
    yield* watch().map((value) => keySet);
  }

  /// Stream that emits firstOrNull on every change for the box, with an optional debounce
  Stream<MapEntry<TKey, TVal>?> firstEntryStream([
    Duration debounceDuration = const Duration(milliseconds: 200),
  ]);

  /// Same as [put], but instead of removing old object, changes (mutates) its values to [newValue]
  Future<void> putAndUpdateExisting(
    TKey key,
    TVal newValue,
    void Function(TKey key, TVal? mutateMe, TVal newValueReadOnly)
        mutateExisting,
  ) async {
    await putAllAndUpdateExisting({key: newValue}, mutateExisting);
  }

  /// Sets the keys and values provided in [newValues].
  Future<void> putAll(Map<TKey, TVal> newValues);

  /// Same as [putAll], but instead of removing old objects, changes (mutates) their values to new values
  Future<void> putAllAndUpdateExisting(
    Map<TKey, TVal> newValues,
    void Function(TKey key, TVal mutateMe, TVal newValueReadOnly)
        mutateExisting,
  );

  /// Same as [putAllAndUpdateExisting] but [mutateExisting] can receive a null existing value
  Future<void> putAllAndUpdateExistingMapped<TMapped>(
    Map<TKey, TMapped> newValues,
    TVal Function(TKey key, TVal? mutateMe, TMapped newValue) mutateExisting,
  );

  /// Clears the box then sets the keys and values provided in [newValues].
  Future<void> assignAll(Map<TKey, TVal> newValues);

  /// Deletes the keys provided in [keys].
  Future<void> deleteKeys(Iterable<TKey> keys);

  /// Deletes all the data in the box.
  Future<void> clear();

  /// Closes the box.
  ///
  /// Be careful, this closes all instances of this box. You have to make sure
  /// that you don't access the box anywhere else after that.
  @override
  Future<void> dispose();
}
