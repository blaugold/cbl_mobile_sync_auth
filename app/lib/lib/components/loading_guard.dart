import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

typedef VoidAsyncCallback = FutureOr<void> Function();

typedef AsyncProviderCreator = FutureOr<List<SingleChildWidget>> Function();

class LoadingGuard extends StatefulWidget {
  const LoadingGuard({
    Key? key,
    this.onCreate,
    this.createProviders,
    this.onDispose,
    required this.child,
  }) : super(key: key);

  final VoidAsyncCallback? onCreate;
  final AsyncProviderCreator? createProviders;
  final VoidCallback? onDispose;
  final Widget child;

  @override
  State<LoadingGuard> createState() => _LoadingGuardState();
}

class _LoadingGuardState extends State<LoadingGuard> {
  late final Future<List<SingleChildWidget>> _initialized;

  @override
  void initState() {
    super.initState();

    final onCreate = Future.sync(widget.onCreate ?? () => null);

    _initialized =
        onCreate.then((_) => Future.sync(widget.createProviders ?? () => []));
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SingleChildWidget>?>(
      future: _initialized,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final providers = snapshot.data!;
          if (providers.isEmpty) {
            return widget.child;
          }
          return MultiProvider(
            providers: snapshot.data!,
            child: widget.child,
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.error,
                    size: 46,
                  ),
                  SizedBox(height: 16),
                  Text('An error occurred'),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
