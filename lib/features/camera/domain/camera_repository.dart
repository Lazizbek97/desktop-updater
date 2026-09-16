abstract interface class CameraRepository {
  Future<({int id, double aspect})> open();
  Future<void> stop();
}
