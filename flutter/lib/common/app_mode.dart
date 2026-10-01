import '../models/platform_model.dart';
import '../consts.dart';

/// Application operational mode:
/// - 'client': Customer Support / SOS / Incoming-Only (compact, simple, no outgoing remote)
/// - 'tech': Technician / Operator Console (full dual-pane, remote ID, address book, tabs, settings)
class AppMode {
  // Compile-time flag passed via: --dart-define=APP_MODE=client or --dart-define=APP_MODE=tech
  static const String _compileTimeMode =
      String.fromEnvironment('APP_MODE', defaultValue: '');

  static String get current {
    // 1. Compile-time flag (set in CI build for client/tech binaries)
    if (_compileTimeMode.isNotEmpty) {
      return _compileTimeMode.toLowerCase();
    }

    // 2. Explicit config option in RustDesk2.toml (e.g. app-mode = 'tech' or 'client')
    try {
      final configMode = bind.mainGetOptionSync(key: 'app-mode').toLowerCase();
      if (configMode == 'tech' || configMode == 'client') {
        return configMode;
      }
    } catch (_) {}

    // 3. Customer lockdown auto-detection:
    // If the customer installer set hide-security-settings = 'Y' or incoming-only,
    // this machine is a customer-facing support client.
    try {
      if (bind.mainGetBuildinOption(key: kOptionHideSecuritySetting) == 'Y' ||
          bind.mainGetOptionSync(key: kOptionHideSecuritySetting) == 'Y' ||
          bind.isIncomingOnly()) {
        return 'client';
      }
    } catch (_) {}

    // 4. Default to 'tech' (Staff / Technician mode with full AnyDesk UI)
    return 'tech';
  }

  static bool get isCustomer => current == 'client';
  static bool get isTech => current == 'tech';
}
