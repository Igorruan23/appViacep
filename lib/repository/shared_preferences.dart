// lib/services/shared_preferences_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<void> saveSearchResult(String cep, Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(cep, jsonEncode(result));
  }

  Future<Map<String, dynamic>?> getSearchResult(String cep) async {
    final prefs = await SharedPreferences.getInstance();
    final resultJson = prefs.getString(cep);
    return resultJson != null ? jsonDecode(resultJson) : null;
  }

  Future<void> removeSearchResult(String cep) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(cep);
  }

  Future<List<Map<String, dynamic>>> getPreviousSearchResults() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final List<Map<String, dynamic>> previousResults = [];

    for (var key in keys) {
      final resultJson = prefs.getString(key);
      if (resultJson != null) {
        final result = jsonDecode(resultJson);
        previousResults.add(result);
      }
    }

    return previousResults;
  }
}
