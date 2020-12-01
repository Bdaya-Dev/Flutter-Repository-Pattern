import 'package:hive/hive.dart';

/// a HiveObject whose key is a string
abstract class GuidHiveObject extends HiveObject {
  @override
  String get key => super.key;
}
