import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

import '../../firebase_options.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return child;
        } else {
          return SignInScreen(
            providerConfigs: [
              if (Platform.isAndroid || Platform.isIOS)
                GoogleProviderConfiguration(
                  // Should not be necessary since we don't support web anyway.
                  // https://github.com/firebase/flutterfire/issues/8440
                  clientId:
                      DefaultFirebaseOptions.currentPlatform.iosClientId ?? '',
                ),
              const EmailProviderConfiguration(),
            ],
          );
        }
      },
    );
  }
}
