/// Utility class for input validation
class Validators {
  /// Validates if a string is not empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validates email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates if a string has minimum length
  static bool hasMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }

  /// Validates if a string has maximum length
  static bool hasMaxLength(String? value, int maxLength) {
    return value != null && value.length <= maxLength;
  }

  /// Validates candidate name
  static String? validateCandidateName(String? name) {
    if (!isNotEmpty(name)) {
      return 'Candidate name is required';
    }
    if (!hasMinLength(name, 2)) {
      return 'Name must be at least 2 characters long';
    }
    if (!hasMaxLength(name, 50)) {
      return 'Name must be less than 50 characters';
    }
    return null; // Valid
  }

  /// Validates interview notes
  static String? validateNotes(String? notes) {
    if (notes != null && !hasMaxLength(notes, 500)) {
      return 'Notes must be less than 500 characters';
    }
    return null; // Valid
  }

  /// Validates if a selection is made
  static String? validateSelection<T>(T? value, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    return null; // Valid
  }

  /// Validates score range
  static String? validateScore(double? score) {
    if (score == null) {
      return 'Score is required';
    }
    if (score < 0 || score > 10) {
      return 'Score must be between 0 and 10';
    }
    return null; // Valid
  }
}
