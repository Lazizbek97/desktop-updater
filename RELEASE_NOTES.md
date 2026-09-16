macOS Apple Silicon laboratory release. Windows testing is deferred.

First install: download `UpdaterLab-osx-arm64-Setup.pkg`. This build is unsigned
and not notarized, so macOS may block it. Only approve this known test build in
Privacy & Security; never disable Gatekeeper globally. Production signing is pending.

Updates check on launch and every four hours while running, download automatically,
and offer Restart to update. Closing and reopening also lets Velopack apply a cached
update at startup. No forced restart during work. Internet is required for discovery
and download, not for applying an already downloaded update via Restart.

Do not install `.nupkg` files: they are updater assets. Retain old GitHub releases
for delta discovery. Full downloads remain a supported fallback.

Not approved for BILLZ production. Original 1.0.0 uses the manual updater flow;
install 1.0.1 as the baseline for automatic-update testing.
