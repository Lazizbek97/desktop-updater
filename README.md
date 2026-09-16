# Desktop Updater Lab

Isolated Flutter 3.38.6 application testing stock `velopack_flutter` 0.3.2 and vpk 1.2.0.
No BILLZ source, credentials, configuration or customer data belongs in this repository.

## Run the experiment

1. Run **Build updater lab** in GitHub Actions with version `1.0.0`.
2. Install the Windows Setup.exe or macOS package from that release. Do not run the bare Flutter build output: Velopack requires its packaged layout.
3. Launch it and confirm the displayed build is 1.0.0. Click Check: no update expected.
4. Keep that installation. Run the workflow with `1.0.1`.
5. In 1.0.0 click Check, then Download. Observe timestamps and whether progress arrives continuously or all at once.
6. Click Apply & restart. Confirm the reopened app shows 1.0.1. Check again: no update expected.
7. Repeat with 1.0.2, including restarting after download with the network disconnected. Record failures rather than assuming a completed stream means successful download.

The app checks on launch and on demand. Download is intentionally manual for reproducible timing. GitHub's `/releases/latest/download` redirects to the current published assets; no app token or external server is required. Both platforms must finish before a release is published. Never overwrite published versions.

## Scope and limits

- Windows x64: packages the complete release directory, including the Rust native library and Flutter assets. Velopack bootstraps `vcredist143-x64`; test on a clean Windows VM without Visual Studio. Unlike BILLZ's bundled VC++ installer, bootstrap may need internet and elevation.
- macOS ARM64: non-sandboxed laboratory build; unsigned and not notarized. Gatekeeper may refuse downloaded builds. Production requires Developer ID signing/notarization and a separate signed test; do not disable machine-wide security settings.
- No automatic migration of an existing BILLZ installation is performed.
- This app does not exercise BILLZ's printers, fiscal devices, Sentry process, databases, single-instance mutex or secure storage. Passing this experiment proves only the basic updater path.
- Stock wrapper has known source-level concerns: progress forwarding starts after download, generated stream code discards a Future that can fail, apply rechecks the remote feed, and startup may automatically apply cached updates. This lab intentionally preserves that behavior so it can be observed before deciding whether to maintain a patched bridge.
- Test network loss, missing assets, insufficient disk, process termination during download, skipped versions, antivirus locks, and successful retry. Save updater logs with OS/version and the exact release pair.
- A reverted app binary does not reverse database migrations. Production rollback needs separate validation.

## Development

Install Flutter 3.38.6 and Rust, then `flutter pub get`, `flutter analyze`, `flutter test`.
Use `flutter run -d macos` for UI only; update operations will report not-installed errors.
Release workflow runs analysis/tests, downloads the prior release to generate deltas, packages both platforms, and publishes assets to GitHub Releases. The first macOS update may be full.
