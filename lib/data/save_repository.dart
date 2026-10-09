import 'package:shared_preferences/shared_preferences.dart';

import 'package:galaxy_defender/data/game_save.dart';

class SaveRepository {
  static const String _key = 'galaxy_defender_save_v1';

  Future<GameSave> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return GameSave.initial();
    }
    try {
      final decoded = Map<String, dynamic>.from(
        __decode(raw),
      );
      return GameSave.fromJson(decoded);
    } catch (_) {
      return GameSave.initial();
    }
  }

  Future<void> save(GameSave save) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, __encode(save.toJson()));
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Map<String, dynamic> __decode(String raw) {
    return Map<String, dynamic>.from(
      raw.split(',').fold<Map<String, dynamic>>(<String, dynamic>{}, (acc, entry) {
        if (entry.isEmpty) return acc;
        final idx = entry.indexOf(':');
        if (idx == -1) return acc;
        final key = entry.substring(0, idx);
        final value = entry.substring(idx + 1);
        acc[key] = value;
        return acc;
      }),
    );
  }

  String __encode(Map<String, dynamic> json) {
    final buffer = StringBuffer();
    final entries = json.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry.value is Map || entry.value is List) {
        buffer.write('${entry.key}:${entry.value.toString()}');
      } else {
        buffer.write('${entry.key}:${entry.value}');
      }
      if (i < entries.length - 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}
