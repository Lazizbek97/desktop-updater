import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/update_repository.dart';

class UpdateCubit extends Cubit<String> {
  UpdateCubit(this._repository) : super('Ready.');
  final UpdateRepository _repository;
  bool busy = false;
  bool readyToRestart = false;
  Timer? _timer;

  void start({
    bool enabled = true,
    Duration interval = const Duration(hours: 4),
  }) {
    if (!enabled) {
      _log('Development preview: install the GitHub release to test updates.');
      return;
    }
    if (_timer != null) return;
    _timer = Timer.periodic(interval, (_) => check());
    unawaited(check());
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await super.close();
  }

  void _log(String message) {
    if (!isClosed) {
      emit(
        '${DateTime.now().toIso8601String()} $message\n$state'
            .split('\n')
            .take(150)
            .join('\n'),
      );
    }
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (busy || isClosed) return;
    busy = true;
    _log('Operation started');
    try {
      await operation();
    } catch (error, stack) {
      if (!isClosed) addError(error, stack);
      _log('FAILED: $error');
    } finally {
      busy = false;
      _log('Operation finished');
    }
  }

  Future<void> check() => _run(() async {
    if (readyToRestart) return;
    final result = await _repository.check();
    _log(result.message);
    if (result.available) await _download();
  });
  Future<void> download() => check();
  Future<void> _download() async {
    var completed = false;
    await for (final progress in _repository.download()) {
      _log('Download: $progress%');
      if (progress == 100) completed = true;
    }
    readyToRestart = completed;
    _log(
      completed
          ? 'Update downloaded. Restart when convenient, or close and reopen.'
          : 'No update downloaded; will check again later.',
    );
  }

  Future<void> restart() => _run(() async {
    if (!readyToRestart) return;
    _log('Applying the downloaded update; no remote recheck.');
    await _repository.restart();
    _log('Restart call returned without terminating the app.');
  });
}
