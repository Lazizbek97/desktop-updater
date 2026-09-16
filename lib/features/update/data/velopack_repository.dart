import 'dart:io';
import 'package:velopack_flutter/velopack_flutter.dart' as velo;
import '../domain/update_repository.dart';

class VelopackRepository implements UpdateRepository {
  static const feed =
      'https://github.com/Lazizbek97/desktop-updater/releases/latest/download';
  Future<void> initialize() => velo.initializeVelopack(
    url: feed,
    channel: Platform.isWindows ? 'win-x64' : 'osx-arm64',
  );
  @override
  Future<String> check() async {
    final current = await velo.currentVersion();
    final next = await velo.getLatestUpdateInfo();
    return next == null
        ? 'Installed $current; no newer release.'
        : 'Installed $current → available ${next.targetFullRelease.version}\nFull package: ${next.targetFullRelease.size} bytes; delta candidates: ${next.deltasToTarget.length}';
  }

  @override
  Stream<int> download() => velo.checkAndDownloadUpdatesWithProgress();
  @override
  Future<void> restart() => velo.updateAndRestart();
}
