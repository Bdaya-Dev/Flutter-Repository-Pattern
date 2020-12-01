import 'package:hive/hive.dart';
import 'repo.dart';

/// An asynchronous repository based on Hive's [LazyBox].
///
/// Keys can be accessed synchronously but values need to be loaded asynchronously
abstract class LazyRepo<TKey, TVal> extends Repo<TKey, TVal> {
  LazyBox<TVal> _box;

  /// The hive box storing the data
  LazyBox<TVal> get dataBox => _box;

  /// Gets the value based on the key
  Future<TVal> getValueById(TKey key) {
    if (key == null) return null;
    return dataBox.get(key);
  }

  /// Notifies the user when any write operations occur.
  ///
  /// Note that this doesn't fire initially.
  Stream<Set<TKey>> listen() =>
      dataBox.watch().map((value) => dataBox.keys.cast<TKey>().toSet());

  @override
  Future<void> init() async {
    _box = await Hive.openLazyBox(boxName);
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
  Future<void> putAll(Map<TKey, TVal> silentMap) async {
    await dataBox.putAll(silentMap);
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
}
