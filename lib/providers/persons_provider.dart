import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/storage_service.dart';

class PersonsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Person> _persons = [];

  List<Person> get persons {
    final sorted = List<Person>.from(_persons);
    sorted.sort(
        (a, b) => a.psychologicalDistance.compareTo(b.psychologicalDistance));
    return sorted;
  }

  Future<void> loadPersons() async {
    _persons = await _storage.loadPersons();
    notifyListeners();
  }

  Future<void> addPerson(Person person) async {
    _persons.add(person);
    await _storage.savePersons(_persons);
    notifyListeners();
  }

  Future<void> updatePerson(Person person) async {
    final index = _persons.indexWhere((p) => p.id == person.id);
    if (index >= 0) {
      _persons[index] = person;
      await _storage.savePersons(_persons);
      notifyListeners();
    }
  }

  Future<void> deletePerson(String id) async {
    _persons.removeWhere((p) => p.id == id);
    await _storage.savePersons(_persons);
    notifyListeners();
  }

  Person? getPersonById(String id) {
    try {
      return _persons.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
