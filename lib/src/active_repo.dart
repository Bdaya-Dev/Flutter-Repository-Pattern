import 'package:hive/hive.dart';
import 'repo.dart';

/// A synchronous repository based on Hive's [Box]
///
/// All keys and values can be accessed synchronously (since it's copied to memory)
abstract class ActiveRepo<TKey, TVal> extends Repo<TKey, TVal> {
  Box<TVal> _box;

  /// The hive box storing the data
  Box<TVal> get dataBox => _box;

  /// Gets the value based on the key
  TVal getValueById(TKey key) {
    if (key == null) {
      return null;
    }
    return dataBox.get(key);
  }

  @override
  Future<void> init() async {
    _box = await Hive.openBox<TVal>(boxName);
  }

  /// Notifies the user when any write operations occur.
  Stream<Map<TKey, TVal>> get stream async* {
    yield getAllValues();
    yield* dataBox.watch().map((value) => getAllValues());
  }

  /// Gets all the values stored in the box
  Map<TKey, TVal> getAllValues() {
    return dataBox.toMap().cast<TKey, TVal>();
  }

  @override
  Future<void> putAll(Map<TKey, TVal> newValues) async {
    await dataBox.putAll(newValues);
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
