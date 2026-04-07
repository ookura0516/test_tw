import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';

class StorageService {
  static const _key = 'persons_data';

  Future<List<Person>> loadPersons() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Person.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePersons(List<Person> persons) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(persons.map((p) => p.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
