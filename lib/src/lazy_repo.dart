import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';
import 'repo.dart';

/// An asynchronous repository based on Hive's [LazyBox].
///
/// Keys can be accessed synchronously but values need to be loaded asynchronously
abstract class LazyRepo<TKey, TVal> extends Repo<TKey, TVal> {
  LazyBox<TVal> _box;

  /// The hive box storing the data
  LazyBox<TVal> get dataBox => _box;

  /// Gets the value based on the key
  Future<TVal> getValueById(TKey key, {TVal defaultValue}) async {
    if (key == null) return null;
    return await dataBox.get(key, defaultValue: defaultValue);
  }

  @override
  Stream<BoxEvent> watch({TKey key}) => dataBox.watch(key: key);

  @override
  Set<TKey> get keys => dataBox.keys.cast<TKey>().toSet();

  /// Creates a stream that listens for specific keys
  @override
  Stream<Map<TKey, TVal>> dataStreamFor(Iterable<TKey> keys) {
    return Rx.combineLatestList<BoxEvent>(
      keys.map(
        (k) async* {
          var val = await dataBox.get(k);
          yield BoxEvent(k, val, val == null);
          yield* dataBox.watch(key: k);
        },
      ),
    ).map(
      (event) {
        return Map.fromEntries(
          event
              .where(
                (z) => !z.deleted,
              )
              .map(
                (z) => MapEntry(
                  z.key,
                  z.value,
                ),
              ),
        );
      },
    );
  }

  @override
  Future<void> init() async {
    _box = await Hive.openLazyBox(boxName);
  }

  /// Gets the first (key,value) stored in the box
  Future<MapEntry<TKey, TVal>> get firstOrNull async {
    var firstOrDefaultKey = dataBox.keys.isEmpty ? null : dataBox.keys.first;
    if (firstOrDefaultKey == null) return null;
    return MapEntry(firstOrDefaultKey, await dataBox.get(firstOrDefaultKey));
  }

  @override
  Stream<MapEntry<TKey, TVal>> firstEntryStream([
    Duration debounceDuration = const Duration(milliseconds: 200),
  ]) async* {
    yield await firstOrNull;
    yield* dataBox
        .watch()
        .debounceTime(debounceDuration) //debounce to prevent spamming the event
        .switchMap((event) => firstOrNull.asStream());
  }

  /// Gets all the values stored in the box.
  ///
  /// Note: this is an expensive operation and can overwhelm the device's memory if there is too much data.
  Future<Map<TKey, TVal>> getAllValues() async {
    final l = <TKey, TVal>{};
    for (var item in dataBox.keys) {
      l[item] = await dataBox.get(item);
    }
    return l;
  }

  @override
  Future<void> putAllAndUpdateExistingMapped<TMapped>(
    Map<TKey, TMapped> newValues,
    TVal Function(TKey key, TVal mutateMe, TMapped newValue) mutateExisting,
  ) async {
    final actualNewValue = <TKey, TVal>{};
    for (var item in newValues.entries) {
      final key = item.key;
      final val = item.value;

      final res = await getValueById(key, defaultValue: null);
      actualNewValue[key] = mutateExisting(key, res, val);
    }
    await putAll(actualNewValue);
  }

  @override
  Future<void> putAll(Map<TKey, TVal> silentMap) async {
    await dataBox.putAll(silentMap);
  }

  @override
  Future<void> putAllAndUpdateExisting(
      Map<TKey, TVal> newValues,
      void Function(TKey key, TVal mutateMe, TVal newValueReadOnly)
          mutateExisting) async {
    final actualNewValue = <TKey, TVal>{};
    for (var item in newValues.entries) {
      final key = item.key;
      final val = item.value;

      //final oldVal = oldValues[key];
      if (!dataBox.containsKey(key)) {
        actualNewValue[key] = val;
      } else {
        final oldVal = await getValueById(key);
        mutateExisting(key, oldVal, val);
        actualNewValue[key] = oldVal;
      }
    }
    await putAll(actualNewValue);
  }

  @override
  Future<void> assignAll(Map<TKey, TVal> newValues) async {
    await dataBox.clear();
    await dataBox.putAll(newValues);
  }

  @override
  Future<void> deleteKeys(Iterable<TKey> keys) async {
    await dataBox.deleteAll(keys);
  }

  @override
  Future<void> clear() async {
    await dataBox.clear();
  }

  @override
  Future<void> dispose() async {
    await dataBox.close();
  }
}
