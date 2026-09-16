# Local laboratory fork of pub.dev velopack_flutter 0.3.2

Original license retained in LICENSE. Rust core pinned to 1.2.0.

- Skip build hooks when buildCodeAssets is false.
- Use unauthenticated GithubSource with repository URL for cross-release delta discovery.
- Forward progress concurrently; join the worker before returning download success.
- Remember successfully downloaded UpdateInfo; Restart applies that exact update offline.
- In generated Dart bridge, propagate task errors into the returned stream and wait
  for both native completion and progress completion before closing.

Generated Dart bridge is intentionally hand-patched; regeneration must reapply and
retest this patch. No FFI signature changes. This is a test fork, not upstream
support or a production guarantee. Unused update/exit APIs retain upstream behavior.
GithubSource has unauthenticated API rate limits shared by public IP; the app checks
every four hours. Large customer fleets need a different feed strategy.
