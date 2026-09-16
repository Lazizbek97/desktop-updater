import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/probe_repository.dart';

class ProbeCubit extends Cubit<String> {
  ProbeCubit(this._repository) : super('Ready to test.');
  final ProbeRepository _repository;
  bool busy = false;
  String savedNote = '';
  Future<void> _run(Future<String> Function() action) async {
    if (busy || isClosed) return;
    busy = true;
    emit('Working…');
    try {
      final message = await action();
      if (!isClosed) emit(message);
    } catch (error, stack) {
      if (!isClosed) {
        addError(error, stack);
        emit('FAILED: $error');
      }
    } finally {
      busy = false;
    }
  }

  Future<void> load() => _run(() async {
    savedNote = await _repository.readNote() ?? '';
    return savedNote.isEmpty
        ? 'No saved note yet.'
        : 'Loaded from SharedPreferences: $savedNote';
  });
  Future<void> save(String note) => _run(() async {
    await _repository.saveNote(note);
    savedNote = await _repository.readNote() ?? '';
    if (savedNote != note) throw StateError('Read-back did not match');
    return 'Saved and read back: $savedNote';
  });
  Future<void> nativeCheck() => _run(_repository.nativeInfo);
}
