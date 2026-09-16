abstract interface class UpdateRepository {
  Future<({String message, bool available})> check();
  Stream<int> download();
  Future<void> restart();
}
