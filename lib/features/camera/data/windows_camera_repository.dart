import 'dart:async';
import 'dart:io';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import '../domain/camera_repository.dart';

class WindowsCameraRepository implements CameraRepository {
  WindowsCameraRepository(this._platform);
  final CameraPlatform _platform;
  int? _id;

  @override
  Future<({int id, double aspect})> open() async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This camera test is Windows-only.');
    }
    final cameras = await _platform.availableCameras();
    if (cameras.isEmpty) {
      throw StateError('No camera detected. Connect a webcam and retry.');
    }
    final id = await _platform.createCameraWithSettings(
      cameras.first,
      const MediaSettings(
        resolutionPreset: ResolutionPreset.medium,
        enableAudio: false,
      ),
    );
    _id = id;
    final initialized = Completer<CameraInitializedEvent>();
    final ready = _platform.onCameraInitialized(id).listen((event) {
      if (!initialized.isCompleted) initialized.complete(event);
    });
    final errors = _platform.onCameraError(id).listen((event) {
      if (!initialized.isCompleted) {
        initialized.completeError(StateError(event.description));
      }
    });
    try {
      // Attach handlers to both futures immediately; neither error is discarded.
      final results = await Future.wait<Object?>([
        _platform.initializeCamera(id),
        initialized.future.timeout(const Duration(seconds: 20)),
      ], eagerError: true);
      final event = results[1] as CameraInitializedEvent;
      return (
        id: id,
        aspect: event.previewHeight > 0
            ? event.previewWidth / event.previewHeight
            : 4 / 3,
      );
    } catch (_) {
      await stop();
      rethrow;
    } finally {
      await ready.cancel();
      await errors.cancel();
    }
  }

  @override
  Future<void> stop() async {
    final id = _id;
    if (id == null) return;
    await _platform.dispose(id);
    _id = null;
  }
}
