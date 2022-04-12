import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../firebase_options.dart';
import 'components/auth_guard.dart';
import 'components/loading_guard.dart';
import 'screens/home_screen.dart';
import 'services/note_service.dart';

const _syncGatewayUrl = 'ws://Gabriels-Mac-mini.local:4984/mobile-sync-demo';
const _syncGatewayUserIdPrefix = 'firebase';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingGuard(
        onCreate: _initializeLibraries,
        child: AuthGuard(
          child: LoadingGuard(
            createProviders: _createProviders,
            child: Home(),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeLibraries() async {
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    CouchbaseLiteFlutter.init()
  ]);

  Database.log.file
    ..level = LogLevel.debug
    ..config = LogFileConfiguration(
      directory: (await getApplicationSupportDirectory()).path,
      usePlainText: true,
    );

  Database.log.custom!.level = LogLevel.info;
}

Future<List<SingleChildWidget>> _createProviders() async {
  final user = FirebaseAuth.instance.currentUser!;
  final userIdToken = await user.getIdToken();
  final noteService = await NoteService.create(
    syncGatewayUrl: _syncGatewayUrl,
    userIdPrefix: _syncGatewayUserIdPrefix,
    userId: user.uid,
    userIdToken: userIdToken,
  );

  return [
    Provider<NoteService>(
      create: (_) => noteService,
      dispose: (_, service) => service.dispose(),
    ),
  ];
}
