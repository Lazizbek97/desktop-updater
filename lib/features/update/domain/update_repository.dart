abstract interface class UpdateRepository {
  Future<String> check();
  Stream<int> download();
  Future<void> restart();
}
