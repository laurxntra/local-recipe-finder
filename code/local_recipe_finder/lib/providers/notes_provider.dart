import 'package:flutter/material.dart';

/// This class is a provider for managing a note for the current recipe.
/// It extends ChangeNotifier to notify listeners when the note changes.
/// It supports undo and redo functionality for the note text.
/// Fields:
/// - _currentNotes: curr note text
/// - _pastNotes: list of past notes for undo functionality
/// - _futureNotes: list of future notes for redo functionality
class NotesProvider extends ChangeNotifier {
  String _currentNotes = ''; // current note text (cached)

  final List<String> _pastNotes = []; // list of past notes for undo

  final List<String> _futureNotes = []; // list of future notes for redo

  String get note => _currentNotes; // getter for current notes

  bool get canUndo =>
      _pastNotes.isNotEmpty; // checks if there are past notes to undo

  bool get canRedo =>
      _futureNotes.isNotEmpty; // checks if there are future notes to redo

  /// This sets the note to a new note by adding to past notes and clearing the future notes for redo.
  /// Notifies listeners of the change.
  /// Parameters:
  /// - newNote: the new note text to set
  /// Returns: N/A
  void setNote(String newNote) {
    if (newNote == _currentNotes) return;
    _pastNotes.add(_currentNotes);
    _currentNotes = newNote;
    _futureNotes.clear();
    notifyListeners();
  }

  /// This undoes the most recent note change by popping from the past notes and adding to future notes.
  /// Also adds it to the current notes.
  /// Notifies listeners of the change.
  /// Parameters: N/A
  /// Returns: N/A
  void undo() {
    if (_pastNotes.isEmpty) return;
    _futureNotes.add(_currentNotes);
    _currentNotes = _pastNotes.removeLast();
    notifyListeners();
  }

  /// This redoes the most recent undone note change by popping from the future notes and adding to past notes.
  /// Also adds it to the current notes.
  /// Notifies listeners of the change.
  /// Parameters: N/A
  /// Returns: N/A
  void redo() {
    if (_futureNotes.isEmpty) return;
    _pastNotes.add(_currentNotes);
    _currentNotes = _futureNotes.removeLast();
    notifyListeners();
  }

  /// This resets the note to a new note, clearing past and future notes.
  /// Notifies listeners of the change.
  /// Parameters:
  /// - newNote: the new note text to set
  /// Returns: N/A
  void reset(String newNote) {
    _currentNotes = newNote;
    _pastNotes.clear();
    _futureNotes.clear();
    notifyListeners();
  }
}
