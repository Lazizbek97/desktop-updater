import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/update_repository.dart';

class UpdateCubit extends Cubit<String> {
  UpdateCubit(this._repository) : super('Ready.');
  final UpdateRepository _repository;
  bool busy = false;
  void _log(String message) {
    if (!isClosed) emit('${DateTime.now().toIso8601String()} $message\n$state');
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (busy) return;
    busy = true;
    _log('Operation started');
    try {
      await operation();
    } catch (error, stack) {
      addError(error, stack);
      _log('FAILED: $error');
    } finally {
      busy = false;
      _log('Operation finished');
    }
  }

  Future<void> check() => _run(() async => _log(await _repository.check()));
  Future<void> download() => _run(() async {
    await for (final progress in _repository.download()) {
      _log('Download: $progress%');
    }
    _log(
      'Stream closed. No progress can mean no update; it is not proof of success.',
    );
  });
  Future<void> restart() => _run(() async {
    _log('Stock wrapper rechecks remote feed before applying.');
    await _repository.restart();
    _log('Restart call returned without terminating the app.');
  });
}
