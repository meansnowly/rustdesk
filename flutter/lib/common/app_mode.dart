import 'dart:io';

/// Application operational mode:
/// - 'client': Customer Support / SOS / Incoming-Only (compact, simple, no outgoing remote)
/// - 'tech': Technician / Operator Console (full dual-pane, remote ID, address book, tabs, settings)
class AppMode {
  // Compile-time flag passed via: --dart-define=APP_MODE=client or --dart-define=APP_MODE=tech
  static const String _compileTimeMode =
      String.fromEnvironment('APP_MODE', defaultValue: '');

  static String get current {
    if (_compileTimeMode.isNotEmpty) {
      return _compileTimeMode.toLowerCase();
    }
    // Runtime fallback:
    // 1. Check executable filename (e.g. Solutionbizsoft-Tech.exe or rustdesk-tech.exe)
    final exe = Platform.resolvedExecutable.toLowerCase();
    if (exe.contains('tech') ||
        exe.contains('operator') ||
        exe.contains('admin')) {
      return 'tech';
    }
    // 2. Default to client (safest for customer facing)
    return 'client';
  }

  static bool get isCustomer => current == 'client';
  static bool get isTech => current == 'tech';
}
