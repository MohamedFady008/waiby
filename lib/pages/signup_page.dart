import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../widgets/auth/auth_page_layout.dart';

/// صفحة إنشاء حساب جديد
/// Sign up page with email/password registration
class SignupPage extends StatefulWidget {
  final AuthController? auth;

  const SignupPage({super.key, this.auth});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // TextEditingControllers للحقول
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // حالة إخفاء/إظهار كلمة المرور
  bool _obscurePassword = true;

  // الحصول على AuthController
  AuthController get _authController =>
      widget.auth ?? Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// إنشاء حساب جديد
  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await _authController.signUp(
      email: email,
      password: password,
      name: name.isNotEmpty ? name : null,
    );

    if (success && mounted) {
      // عرض رسالة التحقق من البريد إذا لزم الأمر
      if (_authController.status.value != AuthStatus.authenticated) {
        // المستخدم بحاجة لتأكيد البريد
        Get.snackbar(
          'Account Created',
          'Please check your email to verify your account before signing in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade600.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        context.go('/login');
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyTextStyle = authBodyTextStyle();
    final linkTextStyle = authLinkTextStyle();

    return AuthPageLayout(
      onClose: () => context.go('/'),
      form: Obx(() {
        final isLoading = _authController.isLoading.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Text(
              'Sign up',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // رابط تسجيل الدخول
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text('Already have an account?', style: bodyTextStyle),
                InkWell(
                  onTap: isLoading ? null : () => context.go('/login'),
                  child: Text('Sign in', style: linkTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 34),

            // حقل الاسم
            TextField(
              controller: _nameController,
              enabled: !isLoading,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: authFieldDecoration('Name'),
            ),
            const SizedBox(height: 16),

            // حقل البريد الإلكتروني
            TextField(
              controller: _emailController,
              enabled: !isLoading,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: authFieldDecoration('Email'),
            ),
            const SizedBox(height: 16),

            // حقل كلمة المرور
            TextField(
              controller: _passwordController,
              enabled: !isLoading,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSignUp(),
              decoration: authFieldDecoration('Password').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                helperText: 'At least 6 characters',
                helperStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // زر إنشاء الحساب
            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton(
                style: authPrimaryButtonStyle(),
                onPressed: isLoading ? null : _handleSignUp,
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Create account',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 18),

            // شروط الاستخدام
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'By creating an account, you confirm that you accept our ',
                  style: bodyTextStyle.copyWith(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                InkWell(
                  onTap: () => Get.snackbar(
                    'Coming Soon',
                    'Terms of Use is not implemented yet.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange.shade600.withValues(
                      alpha: 0.9,
                    ),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  ),
                  child: Text(
                    'Terms of Use',
                    style: linkTextStyle.copyWith(fontSize: 12),
                  ),
                ),
                Text(
                  ' and ',
                  style: bodyTextStyle.copyWith(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                InkWell(
                  onTap: () => Get.snackbar(
                    'Coming Soon',
                    'Privacy Policy is not implemented yet.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange.shade600.withValues(
                      alpha: 0.9,
                    ),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  ),
                  child: Text(
                    'Privacy Policy',
                    style: linkTextStyle.copyWith(fontSize: 12),
                  ),
                ),
                Text(
                  '.',
                  style: bodyTextStyle.copyWith(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
