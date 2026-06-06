import 'dart:convert';
import 'package:crypto/crypto.dart' show sha256;
import 'package:focus_lock/data/repositories/settings_repository.dart';
import 'package:focus_lock/services/logger_service.dart';

class ValidateChallenge {
  final SettingsRepository _settingsRepo = SettingsRepository();

  /// Validates a barcode scan challenge.
  /// Returns true if the scanned barcode matches the saved one.
  bool validateBarcode(String scannedValue) {
    final settings = _settingsRepo.getSettings();

    if (!settings.hasSavedBarcode) {
      LoggerService.warning('No barcode saved for validation');
      return false;
    }

    final scannedHash = _hashValue(scannedValue);
    final matches = scannedHash == settings.savedBarcodeHash;

    LoggerService.info('Barcode validation: ${matches ? "MATCH" : "NO MATCH"}');
    return matches;
  }

  /// Validates a typing challenge.
  /// Returns a TypingValidationResult with details.
  TypingValidationResult validateTyping(String typed, String expected) {
    if (typed == expected) {
      LoggerService.info('Typing challenge: PASSED');
      return TypingValidationResult(
        isCorrect: true,
        errorPositions: [],
        typedLength: typed.length,
        expectedLength: expected.length,
      );
    }

    // Find error positions for visual feedback
    final errors = <int>[];
    final minLen =
        typed.length < expected.length ? typed.length : expected.length;

    for (int i = 0; i < minLen; i++) {
      if (typed[i] != expected[i]) {
        errors.add(i);
      }
    }

    // Characters beyond expected length are also errors
    if (typed.length > expected.length) {
      for (int i = expected.length; i < typed.length; i++) {
        errors.add(i);
      }
    }

    LoggerService.info(
      'Typing challenge: FAILED with ${errors.length} errors',
    );
    return TypingValidationResult(
      isCorrect: false,
      errorPositions: errors,
      typedLength: typed.length,
      expectedLength: expected.length,
    );
  }

  /// Real-time character-by-character validation for UI feedback.
  List<CharacterStatus> getCharacterStatuses(String typed, String expected) {
    final statuses = <CharacterStatus>[];

    for (int i = 0; i < expected.length; i++) {
      if (i >= typed.length) {
        statuses.add(CharacterStatus.pending);
      } else if (typed[i] == expected[i]) {
        statuses.add(CharacterStatus.correct);
      } else {
        statuses.add(CharacterStatus.incorrect);
      }
    }

    return statuses;
  }

  /// Hash a barcode value for storage.
  static String hashBarcode(String value) {
    return _hashValue(value);
  }

  static String _hashValue(String value) {
    final bytes = utf8.encode(value);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class TypingValidationResult {
  final bool isCorrect;
  final List<int> errorPositions;
  final int typedLength;
  final int expectedLength;

  const TypingValidationResult({
    required this.isCorrect,
    required this.errorPositions,
    required this.typedLength,
    required this.expectedLength,
  });

  double get accuracy {
    if (expectedLength == 0) return 0;
    final correct = typedLength - errorPositions.length;
    return (correct / expectedLength * 100).clamp(0, 100);
  }

  bool get isComplete => typedLength >= expectedLength;
}

enum CharacterStatus {
  pending,
  correct,
  incorrect,
}
