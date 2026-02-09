import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../widgets/auth/auth_page_layout.dart';

/// صفحة تسجيل الدخول
/// Login page with email/password and social auth
class LoginPage extends StatefulWidget {
  final AuthController? auth;

  const LoginPage({super.key, this.auth});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // TextEditingControllers للحقول
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // حالة تذكرني
  bool _rememberMe = false;

  // حالة إخفاء/إظهار كلمة المرور
  bool _obscurePassword = true;

  // الحصول على AuthController
  AuthController get _authController =>
      widget.auth ?? Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// تسجيل الدخول بالبريد الإلكتروني
  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await _authController.signIn(
      email: email,
      password: password,
    );

    if (success && mounted) {
      context.go('/');
    }
  }

  /// تسجيل الدخول عبر Google
  Future<void> _handleGoogleLogin() async {
    final success = await _authController.signInWithGoogle();

    if (success && mounted) {
      context.go('/');
    }
  }

  /// تسجيل الدخول عبر Facebook
  Future<void> _handleFacebookLogin() async {
    final success = await _authController.signInWithFacebook();

    if (success && mounted) {
      context.go('/');
    }
  }

  /// عرض رسالة غير متوفر
  void _showNotImplemented(String label) {
    Get.snackbar(
      'Coming Soon',
      '$label is not implemented yet.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade600.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// إعادة تعيين كلمة المرور
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Info',
        'Please enter your email first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade600.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    await _authController.resetPassword(email);
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
              'Sign in',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // رابط التسجيل
            Text("If you don't have an account", style: bodyTextStyle),
            const SizedBox(height: 6),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text('You can', style: bodyTextStyle),
                InkWell(
                  onTap: isLoading ? null : () => context.go('/signup'),
                  child: Text('Register here', style: linkTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 34),

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
              onSubmitted: (_) => _handleEmailLogin(),
              decoration: authFieldDecoration('Password').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // تذكرني ونسيت كلمة المرور
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;
                final remember = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: authAccentBlue,
                      onChanged: isLoading
                          ? null
                          : (value) =>
                                setState(() => _rememberMe = value ?? false),
                    ),
                    Flexible(
                      child: Text(
                        'Remember me',
                        style: bodyTextStyle.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                );
                final forgot = TextButton(
                  onPressed: isLoading ? null : _handleForgotPassword,
                  child: Text(
                    'Forgot password?',
                    style: linkTextStyle.copyWith(
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      remember,
                      Align(alignment: Alignment.centerRight, child: forgot),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: remember),
                    forgot,
                  ],
                );
              },
            ),
            const SizedBox(height: 14),

            // زر تسجيل الدخول
            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton(
                style: authPrimaryButtonStyle(),
                onPressed: isLoading ? null : _handleEmailLogin,
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
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 22),

            // الفاصل
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or continue with',
                    style: bodyTextStyle.copyWith(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
              ],
            ),
            const SizedBox(height: 16),

            // أزرار Social Auth
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _SocialIconButton(
                  tooltip: 'Continue with Google',
                  icon: FontAwesomeIcons.google,
                  onPressed: isLoading ? () {} : _handleGoogleLogin,
                ),
                _SocialIconButton(
                  tooltip: 'Continue with Facebook',
                  icon: FontAwesomeIcons.facebookF,
                  onPressed: isLoading ? () {} : _handleFacebookLogin,
                ),
                _SocialIconButton(
                  tooltip: 'Continue with Apple',
                  icon: FontAwesomeIcons.apple,
                  onPressed: isLoading
                      ? () {}
                      : () => _showNotImplemented('Apple sign-in'),
                ),
                _SocialIconButton(
                  tooltip: 'Continue with Discord',
                  icon: FontAwesomeIcons.discord,
                  onPressed: isLoading
                      ? () {}
                      : () => _showNotImplemented('Discord sign-in'),
                ),
              ],
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
                    color: Colors.white.withOpacity(0.55),
                  ),
                ),
                InkWell(
                  onTap: () => _showNotImplemented('Terms of Use'),
                  child: Text(
                    'Terms of Use',
                    style: linkTextStyle.copyWith(fontSize: 12),
                  ),
                ),
                Text(
                  ' and ',
                  style: bodyTextStyle.copyWith(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.55),
                  ),
                ),
                InkWell(
                  onTap: () => _showNotImplemented('Privacy Policy'),
                  child: Text(
                    'Privacy Policy',
                    style: linkTextStyle.copyWith(fontSize: 12),
                  ),
                ),
                Text(
                  '.',
                  style: bodyTextStyle.copyWith(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.55),
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

/// زر التسجيل عبر مواقع التواصل
class _SocialIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.08),
          highlightColor: Colors.white.withOpacity(0.05),
          onTap: onPressed,
          child: Ink(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Center(child: FaIcon(icon, size: 20, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
