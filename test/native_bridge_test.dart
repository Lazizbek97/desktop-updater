import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:velopack_flutter/velopack_flutter.dart' as velo;
import 'package:velopack_flutter/src/rust/api/velopack.dart' as native;

void main() {
  test(
    'native download failure reaches stream without an unhandled future',
    () async {
      // flutter_tester is deliberately not a Velopack installation. The native
      // manager fails before any GitHub request; this exercises the real FFI error.
      await velo.VelopackRustLib.init(
        externalLibrary: ExternalLibrary.open(
          Platform.isWindows
              ? '${Directory.current.path}/build/native_assets/windows/velopack_flutter.dll'
              : '${Directory.current.path}/build/native_assets/macos/libvelopack_flutter.dylib',
        ),
      );
      await native.initVelopack(
        url: 'https://github.com/Lazizbek97/desktop-updater',
        channel: Platform.isWindows ? 'win-x64' : 'osx-arm64',
        allowDowngrade: false,
      );
      await expectLater(
        velo.checkAndDownloadUpdatesWithProgress(),
        emitsInOrder([emitsError(anything), emitsDone]),
      );
    },
  );
}
