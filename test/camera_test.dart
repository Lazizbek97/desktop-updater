import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:updater_lab/features/camera/domain/camera_repository.dart';
import 'package:updater_lab/features/camera/presentation/camera_cubit.dart';

class FakeCamera implements CameraRepository {
  int opens = 0;
  int stops = 0;
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<({int id, double aspect})> open() async {
    opens++;
    await gate?.future;
    if (fail) throw StateError('Permission denied');
    return (id: 42, aspect: 4 / 3);
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

void main() {
  test('camera only opens on request and closes with screen', () async {
    final camera = FakeCamera();
    final cubit = CameraCubit(camera);
    expect(camera.opens, 0);
    await cubit.start();
    await cubit.start();
    expect(camera.opens, 1);
    expect(cubit.cameraId, 42);
    await cubit.close();
    expect(camera.stops, 1);
  });
  test('permission failure is visible and permits retry', () async {
    final camera = FakeCamera()..fail = true;
    final cubit = CameraCubit(camera);
    await cubit.start();
    expect(cubit.state, contains('Permission denied'));
    expect(cubit.busy, false);
    camera.fail = false;
    await cubit.start();
    expect(cubit.cameraId, 42);
    await cubit.close();
  });
  test('leaving during initialization waits then releases camera', () async {
    final camera = FakeCamera()..gate = Completer<void>();
    final cubit = CameraCubit(camera);
    final opening = cubit.start();
    final closing = cubit.close();
    camera.gate!.complete();
    await Future.wait([opening, closing]);
    expect(camera.stops, 1);
    expect(cubit.isClosed, true);
  });
}
