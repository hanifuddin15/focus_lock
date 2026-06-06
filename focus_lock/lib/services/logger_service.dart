import 'dart:developer' as developer;

class LoggerService {
  static final List<String> _logs = [];
  static const int _maxLogs = 500;

  static void info(String message) {
    _log('INFO', message);
  }

  static void warning(String message) {
    _log('WARN', message);
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    _log('ERROR', message);
    if (error != null) {
      _log('ERROR', 'Error details: $error');
    }
    if (stack != null) {
      _log('ERROR', 'Stack trace: $stack');
    }
  }

  static void debug(String message) {
    _log('DEBUG', message);
  }

  static void _log(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] [$level] $message';

    // Console output
    developer.log(
      message,
      name: 'FocusLock',
      level: _levelToInt(level),
    );

    // Store in memory
    _logs.add(logEntry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
  }

  static int _levelToInt(String level) {
    switch (level) {
      case 'DEBUG':
        return 500;
      case 'INFO':
        return 800;
      case 'WARN':
        return 900;
      case 'ERROR':
        return 1000;
      default:
        return 800;
    }
  }

  static List<String> getRecentLogs([int count = 50]) {
    final start = _logs.length > count ? _logs.length - count : 0;
    return _logs.sublist(start);
  }

  static void clearLogs() {
    _logs.clear();
  }
}
