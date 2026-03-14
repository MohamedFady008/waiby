/// Validators for the Become a Creator form fields.
class CreatorValidators {
  CreatorValidators._();

  /// Minimum age required to apply as a creator.
  static const int minimumAge = 18;

  /// Maximum allowed file size for identity documents (10 MB).
  static const int maxFileSize = 10 * 1024 * 1024;

  /// Allowed file extensions for identity documents.
  static const List<String> allowedFileExtensions = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'webp',
  ];

  /// Allowed MIME types for identity documents.
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'application/pdf',
  ];

  // ── Text field validators ──────────────────────────────────────────

  static String? validateFullLegalName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full legal name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (trimmed.length > 100) {
      return 'Name must be at most 100 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s\-'\.]+$").hasMatch(trimmed)) {
      return 'Name contains invalid characters';
    }
    return null;
  }

  static String? validateDateOfBirth(DateTime? dob) {
    if (dob == null) {
      return 'Date of birth is required';
    }
    final now = DateTime.now();
    final age =
        now.year -
        dob.year -
        ((now.month < dob.month ||
                (now.month == dob.month && now.day < dob.day))
            ? 1
            : 0);
    if (age < minimumAge) {
      return 'You must be at least $minimumAge years old to apply';
    }
    if (age > 120) {
      return 'Please enter a valid date of birth';
    }
    return null;
  }

  static String? validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Country of residence is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid country';
    }
    return null;
  }

  static String? validateDiscordUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Discord username is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 32) {
      return 'Discord username must be 2-32 characters';
    }
    return null;
  }

  static String? validatePrimaryLanguages(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Primary language(s) is required';
    }
    return null;
  }

  static String? validateAboutYourself(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please tell us about yourself';
    }
    if (value.trim().length < 20) {
      return 'Please write at least 20 characters';
    }
    if (value.trim().length > 500) {
      return 'Maximum 500 characters allowed';
    }
    return null;
  }

  static String? validateWhyCreator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please tell us why you want to become a creator';
    }
    if (value.trim().length < 20) {
      return 'Please write at least 20 characters';
    }
    if (value.trim().length > 500) {
      return 'Maximum 500 characters allowed';
    }
    return null;
  }

  // ── File validators ────────────────────────────────────────────────

  /// Validates the file extension.
  static String? validateFileExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (!allowedFileExtensions.contains(ext)) {
      return 'File type not allowed. Accepted: ${allowedFileExtensions.join(", ")}';
    }
    return null;
  }

  /// Validates the file size in bytes.
  static String? validateFileSize(int sizeInBytes) {
    if (sizeInBytes <= 0) {
      return 'File appears to be empty';
    }
    if (sizeInBytes > maxFileSize) {
      final maxMB = maxFileSize / (1024 * 1024);
      return 'File size exceeds ${maxMB.toStringAsFixed(0)} MB limit';
    }
    return null;
  }

  /// Validates the MIME type.
  static String? validateMimeType(String? mimeType) {
    if (mimeType == null || !allowedMimeTypes.contains(mimeType)) {
      return 'Invalid file type. Accepted: JPG, PNG, WebP, PDF';
    }
    return null;
  }

  /// Validates all form fields at once. Returns null if all valid,
  /// or the first error message encountered.
  static String? validateAllFields({
    required String? fullLegalName,
    required DateTime? dateOfBirth,
    required String? country,
    required String? discordUsername,
    required String? primaryLanguages,
    required String? aboutYourself,
    required String? whyCreator,
  }) {
    return validateFullLegalName(fullLegalName) ??
        validateDateOfBirth(dateOfBirth) ??
        validateCountry(country) ??
        validateDiscordUsername(discordUsername) ??
        validatePrimaryLanguages(primaryLanguages) ??
        validateAboutYourself(aboutYourself) ??
        validateWhyCreator(whyCreator);
  }
}
