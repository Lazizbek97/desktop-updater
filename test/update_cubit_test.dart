import 'package:flutter_test/flutter_test.dart';
import 'package:updater_lab/features/update/domain/update_repository.dart';
import 'package:updater_lab/features/update/presentation/update_cubit.dart';

class FakeRepository implements UpdateRepository {
  bool fail = false;
  bool available = true;
  bool downloadFails = false;
  int downloads = 0;
  int restarts = 0;
  @override
  Future<({String message, bool available})> check() async {
    if (fail) throw StateError('offline');
    return (message: 'Installed 1.0.0', available: available);
  }

  @override
  Stream<int> download() async* {
    downloads++;
    yield 50;
    if (downloadFails) throw StateError('download interrupted');
    yield 100;
  }

  @override
  Future<void> restart() async {
    restarts++;
  }
}

void main() {
  test(
    'available update downloads automatically, restart remains explicit',
    () async {
      final repository = FakeRepository();
      final cubit = UpdateCubit(repository);
      await cubit.check();
      expect(repository.downloads, 1);
      expect(repository.restarts, 0);
      expect(cubit.readyToRestart, isTrue);
      await cubit.check();
      expect(repository.downloads, 1);
      await cubit.restart();
      expect(repository.restarts, 1);
      await cubit.close();
    },
  );
  test('failed download cannot enable restart and can retry', () async {
    final repository = FakeRepository()..downloadFails = true;
    final cubit = UpdateCubit(repository);
    await cubit.check();
    expect(cubit.readyToRestart, isFalse);
    await cubit.restart();
    expect(repository.restarts, 0);
    repository.downloadFails = false;
    await cubit.check();
    expect(cubit.readyToRestart, isTrue);
    await cubit.close();
  });
  test('no update causes no download', () async {
    final repository = FakeRepository()..available = false;
    final cubit = UpdateCubit(repository);
    await cubit.check();
    expect(repository.downloads, 0);
    expect(cubit.readyToRestart, isFalse);
    await cubit.close();
  });
  test('debug preview makes no update request', () async {
    final repository = FakeRepository();
    final cubit = UpdateCubit(repository)..start(enabled: false);
    expect(cubit.state, contains('Development preview'));
    expect(repository.downloads, 0);
    await cubit.close();
  });
  test('failure permits retry', () async {
    final repository = FakeRepository()..fail = true;
    final cubit = UpdateCubit(repository);
    await cubit.check();
    expect(cubit.state, contains('FAILED'));
    expect(cubit.busy, isFalse);
    repository.fail = false;
    await cubit.check();
    expect(cubit.state, contains('Installed 1.0.0'));
    await cubit.close();
  });
}
