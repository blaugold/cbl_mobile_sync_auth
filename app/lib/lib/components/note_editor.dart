import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../services/note_service.dart';
import '../utils/flutter_utils.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({Key? key}) : super(key: key);

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final StreamSubscription _noteSub;
  late final StreamSubscription _noteSaveSub;
  final _noteController = TextEditingController();
  var _dirty = false;
  var _pendingSaveRequests = 0;

  @override
  void initState() {
    super.initState();

    final noteService = context.read<NoteService>();

    _noteSaveSub = _noteController
        .asStream()
        .map((value) => value.text)
        .distinct()
        .doOnData((_) => _dirty = true)
        .debounceTime(const Duration(milliseconds: 500))
        .doOnData((_) => _pendingSaveRequests++)
        .asyncMap(noteService.saveNote)
        .doOnData((_) {
      _pendingSaveRequests--;
      if (_pendingSaveRequests == 0) {
        _dirty = false;
      }
    }).listen(null);

    _noteSub = noteService.noteStream().listen((note) {
      if (!_dirty && note != _noteController.text) {
        _noteController.value = _noteController.value.copyWith(text: note);
      }
    });

    noteService.setReplicationEnabled(true);
  }

  @override
  void dispose() {
    _noteSaveSub.cancel();
    _noteSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration.collapsed(
        hintText: 'Note',
      ),
      controller: _noteController,
      maxLines: null,
      expands: true,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
