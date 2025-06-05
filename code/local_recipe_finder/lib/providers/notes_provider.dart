import 'package:flutter/material.dart';

class NotesProvider extends ChangeNotifier {
  String _currentNotes = '';

  final List<String> _pastNotes = [];

  final List<String> _futureNotes = [];

  String get note => _currentNotes;

  bool get canUndo => _pastNotes.isNotEmpty;

  bool get canRedo => _futureNotes.isNotEmpty;

  void setNote(String newNote) {
    if (newNote == _currentNotes) return;
    _pastNotes.add(_currentNotes);
    _currentNotes = newNote;
    _futureNotes.clear();
    notifyListeners();
  }

  void undo() {
    if(_pastNotes.isEmpty) return;
    _futureNotes.add(_currentNotes);
    _currentNotes = _pastNotes.removeLast();
    notifyListeners();
  }

  void redo() {
    if (_futureNotes.isEmpty) return;
    _pastNotes.add(_currentNotes);
    _currentNotes = _futureNotes.removeLast();
    notifyListeners();
  }

  void reset(String newNote) {
    _currentNotes = newNote;
    _pastNotes.clear();
    _futureNotes.clear();
    notifyListeners();
  }

}