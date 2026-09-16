import 'dart:io';
import 'package:velopack_flutter/velopack_flutter.dart' as velo;
import '../domain/update_repository.dart';

class VelopackRepository implements UpdateRepository {
  static const feed = 'https://github.com/Lazizbek97/desktop-updater';
  Future<void> initialize() => velo.initializeVelopack(
    url: feed,
    channel: Platform.isWindows ? 'win-x64' : 'osx-arm64',
  );
  @override
  Future<({String message, bool available})> check() async {
    final current = await velo.currentVersion();
    final next = await velo.getLatestUpdateInfo();
    final message = next == null
        ? 'Installed $current; no newer release.'
        : 'Installed $current → available ${next.targetFullRelease.version}\nFull package: ${next.targetFullRelease.size} bytes; delta candidates: ${next.deltasToTarget.length}';
    return (message: message, available: next != null);
  }

  @override
  Stream<int> download() => velo.checkAndDownloadUpdatesWithProgress();
  @override
  Future<void> restart() => velo.updateAndRestart();
}
