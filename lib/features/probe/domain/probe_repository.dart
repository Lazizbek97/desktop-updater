abstract interface class ProbeRepository {
  Future<String?> readNote();
  Future<void> saveNote(String note);
  Future<String> nativeInfo();
}
