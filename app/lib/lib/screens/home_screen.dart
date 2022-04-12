import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/note_editor.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: FirebaseAuth.instance.signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const SafeArea(
        minimum: EdgeInsets.all(16),
        child: NoteEditor(),
      ),
    );
  }
}
