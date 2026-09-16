import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/probe_repository.dart';

class LocalProbeRepository implements ProbeRepository {
  LocalProbeRepository(this._preferences, this._channel);
  final SharedPreferencesAsync _preferences;
  final MethodChannel _channel;
  static const noteKey = 'updater_lab.persistence_note.v1';

  @override
  Future<String?> readNote() => _preferences.getString(noteKey);
  @override
  Future<void> saveNote(String note) => _preferences.setString(noteKey, note);
  @override
  Future<String> nativeInfo() async {
    if (!Platform.isWindows) return 'Native C++ probe is Windows-only.';
    final result = await _channel.invokeMethod<String>('getNativeInfo');
    if (result == null) throw StateError('Native probe returned no result');
    return result;
  }
}
