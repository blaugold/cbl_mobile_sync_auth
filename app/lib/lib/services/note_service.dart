import 'package:cbl/cbl.dart';

import '../utils/cbl_utils.dart';

class NoteService {
  static Future<NoteService> create({
    required String syncGatewayUrl,
    required String userIdPrefix,
    required String userId,
    required String userIdToken,
  }) async {
    final service = NoteService._(
      syncGatewayUrl,
      userIdPrefix,
      userId,
      userIdToken,
    );
    await service._initialize();
    return service;
  }

  NoteService._(
    this._syncGatewayUrl,
    this._userIdPrefix,
    this._userId,
    this._userIdToken,
  );

  final String _syncGatewayUrl;
  final String _userIdPrefix;
  final String _userId;
  final String _userIdToken;
  late final Database _db;
  late final Replicator _replicator;
  late MutableDocument _noteDoc;

  Future<void> _initialize() async {
    // await Database.remove('data');
    _db = await Database.openAsync('data');
    _replicator = await _createReplicator(continuous: true);
    _noteDoc = await _ensureNoteDoc();
  }

  Future<Replicator> _createReplicator({required bool continuous}) =>
      Replicator.createAsync(ReplicatorConfiguration(
        database: _db,
        target: UrlEndpoint(Uri.parse(_syncGatewayUrl)),
        headers: {'Authorization': 'Bearer $_userIdToken'},
        continuous: continuous,
      ));

  Future<MutableDocument> _ensureNoteDoc() async {
    final syncGatewayUserId = '${_userIdPrefix}_$_userId';
    final noteDocId = 'note_$_userId';

    // Try to load the note directly from the local database.
    var noteDoc = (await _db.document(noteDocId))?.toMutable();
    if (noteDoc != null) {
      return noteDoc;
    }

    // If the note doesn't exist locally, replicate with the sync gateway in
    // case it was created on another device and pushed.
    final initDbReplicator = await _createReplicator(continuous: false);
    await initDbReplicator.startAndWaitUntilStopped();
    noteDoc = (await _db.document(noteDocId))?.toMutable();
    if (noteDoc != null) {
      return noteDoc;
    }

    // If the note still doesn't exist, create it.
    noteDoc = MutableDocument.withId(noteDocId, {
      'owner': syncGatewayUserId,
      'content': '',
    });
    await _db.saveDocument(noteDoc);
    return noteDoc;
  }

  String get currentNote => _noteDoc.string('content')!;

  Stream<String> noteStream() async* {
    yield currentNote;

    // TODO: Listen specifically to changes of the note document.
    // https://github.com/couchbase/couchbase-lite-C/issues/291
    // ignore: no_leading_underscores_for_local_identifiers
    await for (final _ in _db.changes()) {
      final currentNoteDoc = await _db.document(_noteDoc.id);
      if (_noteDoc.revisionId != currentNoteDoc!.revisionId) {
        _noteDoc = currentNoteDoc.toMutable();
        yield currentNote;
      }
    }
  }

  Future<void> saveNote(String content) async {
    _noteDoc.setString(content, key: 'content');
    await _db.saveDocument(_noteDoc);
  }

  Future<void> setReplicationEnabled(bool enabled) async {
    if (enabled) {
      await _replicator.start();
    } else {
      await _replicator.stop();
    }
  }

  Future<void> dispose() => _db.close();
}
