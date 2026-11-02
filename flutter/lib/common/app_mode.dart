import 'dart:io';

/// Application operational mode:
/// - 'client': Customer Support / SOS / Incoming-Only (compact, simple, no outgoing remote)
/// - 'tech': Technician / Operator Console (full dual-pane, remote ID, address book, tabs, settings)
class AppMode {
  // Compile-time flag passed via: --dart-define=APP_MODE=client or --dart-define=APP_MODE=tech
  // Can also be patched directly by CI before building each variant.
  static const String _compileTimeMode =
      String.fromEnvironment('APP_MODE', defaultValue: 'client');

  static bool _isTechIdentifier(String value) {
    final v = value.toLowerCase();
    return v.contains('tech') ||
        v.contains('staff') ||
        v.contains('operator') ||
        v.contains('admin');
  }

  static String get current {
    // 1. Check portable wrapper environment variable (outer .exe name)
    final portableAppName = Platform.environment['RUSTDESK_APPNAME'] ?? '';
    if (_isTechIdentifier(portableAppName)) {
      return 'tech';
    }
    // 2. Check resolved inner executable filename (e.g. rustdesk-tech.exe)
    final exe = Platform.resolvedExecutable;
    if (_isTechIdentifier(exe)) {
      return 'tech';
    }
    // 3. Use compile-time mode ('client' or 'tech')
    if (_compileTimeMode.isNotEmpty) {
      return _compileTimeMode.toLowerCase();
    }
    return 'client';
  }

  static bool get isCustomer => current == 'client';
  static bool get isTech => current == 'tech';
}
