import 'package:hive/hive.dart';
import 'repo.dart';
import 'package:rxdart/rxdart.dart';

/// A synchronous repository based on Hive's [Box]
///
/// All keys and values can be accessed synchronously (since it's copied to memory)
abstract class ActiveRepo<TKey, TVal> extends Repo<TKey, TVal> {
  Box<TVal> _box;

  /// The hive box storing the data
  Box<TVal> get dataBox => _box;

  /// Gets the value based on the key
  TVal getValueById(TKey key, {TVal defaultValue}) {
    if (key == null) {
      return null;
    }
    return dataBox.get(key, defaultValue: defaultValue);
  }

  @override
  Future<void> init() async {
    _box = await Hive.openBox<TVal>(boxName);
  }

  /// Notifies the user when any write operations occur.
  Stream<Map<TKey, TVal>> get dataStream async* {
    yield getAllValues();
    yield* dataBox.watch().map((value) => getAllValues());
  }

  @override
  Iterable<TKey> get keys => dataBox.keys.cast<TKey>();

  @override
  Stream<BoxEvent> watch({TKey key}) => dataBox.watch(key: key);

  /// Creates a stream that listens for specific keys
  @override
  Stream<Map<TKey, TVal>> dataStreamFor(Iterable<TKey> keys) {
    return Rx.combineLatestList<BoxEvent>(
      keys.map(
        (k) async* {
          var val = dataBox.get(k);
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

  /// Gets all the values stored in the box
  Map<TKey, TVal> getAllValues() {
    return dataBox.toMap().cast<TKey, TVal>();
  }

  /// Gets the first (key,value) stored in the box
  MapEntry<TKey, TVal> get firstOrNull {
    var firstOrDefaultKey = firstOrNullKey;
    if (firstOrDefaultKey == null) return null;
    return MapEntry(firstOrDefaultKey, dataBox.get(firstOrDefaultKey));
  }

  @override
  Stream<MapEntry<TKey, TVal>> firstEntryStream([
    Duration debounceDuration = const Duration(milliseconds: 200),
  ]) async* {
    yield firstOrNull;
    yield* dataBox
        .watch()
        .debounceTime(debounceDuration) //debounce to prevent spamming the event
        .map((event) => firstOrNull);
  }

  @override
  Future<void> putAll(Map<TKey, TVal> newValues) async {
    await dataBox.putAll(newValues);
  }

  @override
  Future<void> putAllAndUpdateExisting(
    Map<TKey, TVal> newValues,
    void Function(TKey key, TVal mutateMe, TVal newValueReadOnly)
        mutateExisting,
  ) async {
    final actualNewValue = <TKey, TVal>{};
    for (var item in newValues.entries) {
      final key = item.key;
      final val = item.value;

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
  Future<void> putAllAndUpdateExistingMapped<TMapped>(
    Map<TKey, TMapped> newValues,
    TVal Function(TKey key, TVal mutateMe, TMapped newValue) mutateExisting,
  ) async {
    final actualNewValue = <TKey, TVal>{};
    for (var item in newValues.entries) {
      final key = item.key;
      final val = item.value;

      final res = getValueById(key, defaultValue: null);
      actualNewValue[key] = mutateExisting(key, res, val);
    }
    await putAll(actualNewValue);
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
