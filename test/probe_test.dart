import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:updater_lab/features/probe/domain/probe_repository.dart';
import 'package:updater_lab/features/probe/presentation/probe_cubit.dart';
import 'package:updater_lab/features/probe/presentation/probe_page.dart';

class FakeProbe implements ProbeRepository {
  String? note;
  bool fail = false;
  @override
  Future<String?> readNote() async => note;
  @override
  Future<void> saveNote(String value) async {
    if (fail) throw StateError('Storage unavailable');
    note = value;
  }

  @override
  Future<String> nativeInfo() async => 'native-probe-v1';
}

void main() {
  test('saved note survives a new cubit; native result is displayed', () async {
    final repository = FakeProbe();
    final first = ProbeCubit(repository);
    await first.save('keep-me-106');
    expect(first.state, contains('Saved and read back'));
    await first.close();
    final second = ProbeCubit(repository);
    await second.load();
    expect(second.state, contains('keep-me-106'));
    await second.nativeCheck();
    expect(second.state, 'native-probe-v1');
    await second.close();
  });
  test('storage failure is visible and allows retry', () async {
    final repository = FakeProbe()..fail = true;
    final cubit = ProbeCubit(repository);
    await cubit.save('note');
    expect(cubit.state, contains('FAILED'));
    expect(cubit.busy, false);
    repository.fail = false;
    await cubit.save('note');
    expect(cubit.state, contains('Saved and read back'));
    await cubit.close();
  });
  testWidgets('probe UI saves typed text and invokes native check', (
    tester,
  ) async {
    final cubit = ProbeCubit(FakeProbe());
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const Scaffold(body: ProbePage()),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'keep-me-106');
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();
    expect(find.text('Saved and read back: keep-me-106'), findsOneWidget);
    await tester.tap(find.text('Run native C++ check'));
    await tester.pumpAndSettle();
    expect(find.text('native-probe-v1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
