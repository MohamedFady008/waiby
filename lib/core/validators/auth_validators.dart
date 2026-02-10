/// صنف يحتوي على دوال التحقق من صحة البيانات للمصادقة
/// Validation class for authentication data validation
class AuthValidators {
  /// التحقق من صحة البريد الإلكتروني
  /// Validates email format using regex pattern
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    // نمط regex للتحقق من صحة البريد الإلكتروني
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  /// التحقق من صحة كلمة المرور
  /// Validates password strength and format
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    // التحقق من وجود حرف كبير
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    // التحقق من وجود حرف صغير
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    // التحقق من وجود رقم
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    return null;
  }

  /// التحقق من صحة الاسم
  /// Validates name is not empty and has minimum length
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'الاسم مطلوب';
    }

    if (name.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    if (name.length > 50) {
      return 'الاسم يجب ألا يتجاوز 50 حرفاً';
    }

    return null;
  }

  /// التحقق من تطابق كلمتي المرور
  /// Validates that password and confirm password match
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (password != confirmPassword) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  /// التحقق من صحة البريد الإلكتروني بتنسيق بسيط (للتسجيل)
  /// Simple email validation for signup
  static String? validateEmailSimple(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// التحقق من صحة كلمة المرور بتنسيق بسيط
  /// Simple password validation
  static String? validatePasswordSimple(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// التحقق من صحة الاسم بتنسيق بسيط
  /// Simple name validation
  static String? validateNameSimple(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }
}
