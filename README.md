# Desktop Updater Lab — macOS first

## Windows 1.0.7 camera DLL experiment

Keep the installed 1.0.6 and its saved note. Update without reinstalling, then:
- Confirm the window restores after restart; report if Windows still leaves it behind another app.
- Open **Camera DLL test**, then **Open camera**. Nothing activates automatically.
- Expect a live local webcam preview. Audio is disabled; no capture, recording or upload is implemented.
- Stop the camera, reopen it, then leave the screen; check the camera indicator turns off.
- Check **Native & saved data → Load saved note** to verify the 1.0.6 note survived.

This adds Flutter's camera_windows plugin, compiled as camera_windows_plugin.dll.
CI verifies this DLL exists and its bytes match the copy inside the full update
package. Hardware preview still requires a real Windows device; CI cannot prove it.
Windows camera privacy policy, another app holding the webcam, or missing Media
Foundation on Windows N editions can prevent preview independently of the updater.
The native window now restores and requests foreground activation; if Windows
denies focus, it flashes the taskbar button rather than forcing always-on-top.

## Windows 1.0.6 native and persistence experiment

Update the installed Windows app to 1.0.6 (do not reinstall). Open the new
**Native & saved data** tab and run **Run native C++ check**. Expect
`native-probe-v1 | Windows C++ executed | Logical processors: ...`.
This method channel was added to the Windows runner in this release, proving new
native executable code can arrive via an update. It is not a third-party DLL test.

Save a non-sensitive note such as `keep-me-106`, then quit/reopen and load it.
SharedPreferencesAsync stores the note outside the application bundle; no startup
code clears it. Leave it saved for the next release to test update preservation.
1.0.5 did not have this note feature, so 1.0.5 → 1.0.6 alone cannot prove retention
of a previously saved note. Preferences are not suitable for critical data and do
not substitute for database migration, backup or corruption-recovery testing.

Windows lab releases now exist; the original macOS-first instructions below
describe the earlier experiment. The macOS shutdown issue remains unresolved.

Isolated Flutter 3.44.8 app with a vendored, patched velopack_flutter 0.3.2 and
Velopack core/CLI 1.2.0. No BILLZ source, credentials or customer data belongs here.
Windows is deferred until macOS passes. Apple Silicon only in this phase.

## Install and test

1. In GitHub Actions run **Release macOS updater lab**, version **1.0.1**.
2. From that release download `UpdaterLab-osx-arm64-Setup.pkg`, install, and open
   the installed app. Do not launch the bare Flutter build or a `.nupkg`.
3. Confirm Build 1.0.1. Leave it installed. Publish **1.0.2** with the same workflow.
4. Click Check to avoid the four-hour timer, or relaunch to trigger startup checking.
   Download happens automatically. App must remain open without forcing a restart.
5. When ready, click Apply & restart. Confirm Build 1.0.2 and no new update.
6. Repeat with 1.0.3: disconnect internet AFTER download, then Apply & restart.
7. Repeat closing normally after download and reopening; verify cached startup update.

Original 1.0.0 is the old manual-flow experiment. Use 1.0.1 as the baseline for
automatic behavior. Do not publish 1.0.2 until the baseline is installed.

These lab installers are unsigned/unnotarized. Gatekeeper may block them; only
approve this known test app through Privacy & Security. Never disable Gatekeeper
globally. Smooth public installation requires Developer ID signing/notarization.
The CLI creates a PKG installer, not a DMG. A DMG is not needed for auto-updates.

## Release pipeline and cost

Manual dispatch is intentional: no expensive builds on every commit. Hotfixes and
regular releases use exactly the same workflow with a higher three-part version.
The workflow builds/tests on standard macos-14, downloads the previous full release,
generates full/delta packages and feed, checks artifacts, uploads a draft, then
publishes it. Failed jobs do not replace the latest release. If upload fails after
draft creation, inspect that draft before choosing a new version; do not overwrite
published versions. Timeout: 35 minutes; intermediate artifacts retained 3 days.

GitHub standard hosted runners are free for public repositories:
https://docs.github.com/en/billing/concepts/product-billing/github-actions
This workflow refuses private repositories to avoid silently introducing private
runner charges. Larger paid runners are not used. Release assets are public;
never upload secrets. No GitHub token is embedded in the app.

Keep old release assets for skipped-version deltas. GithubSource searches recent
releases; if a delta chain is unavailable it can download a full package. A first
macOS update may be full. Patching is an optimization, not a guaranteed download size.
Unauthenticated GitHub API limits are shared per public IP. Four-hour polling suits
this small lab; GitHub API-based polling needs reevaluation for a large BILLZ fleet.

## Acceptance checklist (not yet passed)

- [ ] Fresh PKG installation launches with correct version and no missing UpdateMac.
- [ ] 1.0.1 → 1.0.2 automatic download and explicit restart, without installer wizard.
- [ ] Downloaded update applies offline; cached update applies on next startup.
- [ ] Offline startup remains usable; reconnect and Check retries successfully.
- [ ] Quit/kill during download, relaunch, retry; no partial update applied.
- [ ] Skip a release; full fallback or complete delta chain succeeds.
- [ ] Compare full/delta sizes; record actual network use, not just candidate count.
- [ ] Insufficient disk and corrupt/missing assets in a separate disposable test feed.
- [ ] Signed/notarized install and update on a clean Mac, including non-admin user.
- [ ] Native dependencies, persistent data and migrations validated before BILLZ integration.

Record OS, architecture, old/new version, app/update logs and outcome. Do not
corrupt public release assets to simulate failure. Do not fill the host disk;
use a disposable VM/volume. This app contains no BILLZ database, printers, fiscal
devices, secure storage or mutex, so these checks cannot prove BILLZ compatibility.

## Development

Install Flutter 3.44.8 and Rust via rustup (toolchain 1.90.0).
Run `flutter pub get`, `flutter analyze`, `flutter test`.
`flutter run -d macos` is a UI preview with update controls disabled.
Actual updates require a Velopack-packaged installation.
See `packages/velopack_flutter/PATCHES.md` for the maintained bridge changes.
