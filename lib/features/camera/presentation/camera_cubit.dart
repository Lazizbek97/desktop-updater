import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/camera_repository.dart';

class CameraCubit extends Cubit<String> {
  CameraCubit(this._repository) : super('Camera is off.');
  final CameraRepository _repository;
  int? cameraId;
  double aspect = 4 / 3;
  bool busy = false;
  Future<void>? _opening;
  Future<void>? _stopping;
  bool _closing = false;
  Future<void> start() async {
    if (busy || cameraId != null || isClosed || _closing || _stopping != null) {
      return;
    }
    busy = true;
    emit('Opening camera…');
    _opening = _open();
    await _opening;
  }

  Future<void> _open() async {
    try {
      final camera = await _repository.open();
      cameraId = camera.id;
      aspect = camera.aspect;
      busy = false;
      if (!isClosed) {
        emit('Live preview — camera_windows native plugin loaded.');
      }
    } catch (error, stack) {
      busy = false;
      if (!isClosed) {
        addError(error, stack);
        emit(
          'Camera unavailable: $error. Check Windows camera privacy settings and other apps using it.',
        );
      }
    }
  }

  Future<void> stop() =>
      _stopping ??= _stop().whenComplete(() => _stopping = null);
  Future<void> _stop() async {
    await _opening;
    try {
      await _repository.stop();
      cameraId = null;
      if (!isClosed) emit('Camera is off.');
    } catch (error, stack) {
      if (!isClosed) {
        addError(error, stack);
        emit('Could not stop camera: $error. Close this test app.');
      }
    }
  }

  @override
  Future<void> close() async {
    _closing = true;
    await stop();
    await super.close();
  }
}
