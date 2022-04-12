import 'package:cbl/cbl.dart';

extension ReplicatorUtils on Replicator {
  Future<void> startAndWaitUntilStopped() async {
    final stopped = changes().firstWhere(
      (change) => change.status.activity == ReplicatorActivityLevel.stopped,
    );

    await start();
    await stopped;
  }
}
