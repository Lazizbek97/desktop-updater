import 'package:flutter_test/flutter_test.dart';
import 'package:updater_lab/features/update/domain/update_repository.dart';
import 'package:updater_lab/features/update/presentation/update_cubit.dart';

class FakeRepository implements UpdateRepository {
  bool fail = false;
  @override
  Future<String> check() async {
    if (fail) throw StateError('offline');
    return 'Installed 1.0.0';
  }

  @override
  Stream<int> download() => Stream.fromIterable([0, 50, 100]);
  @override
  Future<void> restart() async {}
}

void main() {
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
