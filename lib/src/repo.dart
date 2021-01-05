abstract class Repo<TKey, TVal> {
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

  /// Same as [put], but instead of removing old object, changes (mutates) its values to [newValue]
  Future<void> putAndUpdateExisting(
    TKey key,
    TVal newValue,
    void Function(TKey key, TVal mutateMe, TVal newValueReadOnly)
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

  /// Clears the box then sets the keys and values provided in [newValues].
  Future<void> assignAll(Map<TKey, TVal> newValues);

  /// Deletes the keys provided in [keys].
  Future<void> deleteKeys(Iterable<TKey> keys);

  /// Deletes all the data in the box.
  Future<void> clear();
}
