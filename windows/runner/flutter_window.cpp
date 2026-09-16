#include "flutter_window.h"

#include <optional>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <string>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  flutter::MethodChannel<flutter::EncodableValue> probe(
      flutter_controller_->engine()->messenger(), "updater_lab/native_probe",
      &flutter::StandardMethodCodec::GetInstance());
  probe.SetMethodCallHandler([](const auto& call, auto result) {
    if (call.method_name() != "getNativeInfo") {
      result->NotImplemented();
      return;
    }
    SYSTEM_INFO info{};
    GetNativeSystemInfo(&info);
    result->Success(flutter::EncodableValue(
        std::string("native-probe-v1 | Windows C++ executed | Logical processors: ") +
        std::to_string(info.dwNumberOfProcessors)));
  });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
    // Restore a launcher-minimized window after the first Flutter frame.
    ::ShowWindow(GetHandle(), SW_RESTORE);
    if (!::SetForegroundWindow(GetHandle())) {
      // Respect Windows focus restrictions instead of forcing an always-on-top window.
      FLASHWINFO attention{};
      attention.cbSize = sizeof(attention);
      attention.hwnd = GetHandle();
      attention.dwFlags = FLASHW_TRAY;
      attention.uCount = 3;
      ::FlashWindowEx(&attention);
    }
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
