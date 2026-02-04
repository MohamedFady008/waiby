import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  final AuthController auth;

  const LoginPage({super.key, required this.auth});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;

  void _showNotImplemented(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label is not implemented yet.')));
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2F88FF), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0D1220);
    const accentBlue = Color(0xFF2F88FF);

    final bodyTextStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.84),
    );

    final linkTextStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: accentBlue,
      decoration: TextDecoration.underline,
      decorationColor: accentBlue,
    );

    return Scaffold(
      backgroundColor: background,
      body: Row(
        children: [
          // LEFT (1 part) — Login Form
          Expanded(
            flex: 1,
            child: SafeArea(
              child: Column(
                children: [
                  _AuthSideBar(onClose: () => context.go('/')),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 20,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sign in",
                                style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "If you don’t have an account",
                                style: bodyTextStyle,
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                children: [
                                  Text("You can", style: bodyTextStyle),
                                  InkWell(
                                    onTap: () => context.go('/signup'),
                                    child: Text(
                                      "Register here",
                                      style: linkTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 34),
                              TextField(
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                decoration: _fieldDecoration("Email"),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration("Password"),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: accentBlue,
                                    onChanged: (value) => setState(
                                      () => _rememberMe = value ?? false,
                                    ),
                                  ),
                                  Text(
                                    "Remember me",
                                    style: bodyTextStyle.copyWith(fontSize: 14),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () =>
                                        _showNotImplemented("Forgot password"),
                                    child: Text(
                                      "Forgot password?",
                                      style: linkTextStyle.copyWith(
                                        fontSize: 14,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 53,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  onPressed: () {
                                    widget.auth.login();
                                    context.go('/');
                                  },
                                  child: Text(
                                    "Login",
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      "or continue with",
                                      style: bodyTextStyle.copyWith(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _SocialIconButton(
                                    tooltip: "Continue with Google",
                                    icon: FontAwesomeIcons.google,
                                    onPressed: () =>
                                        _showNotImplemented("Google sign-in"),
                                  ),
                                  _SocialIconButton(
                                    tooltip: "Continue with Facebook",
                                    icon: FontAwesomeIcons.facebookF,
                                    onPressed: () =>
                                        _showNotImplemented("Facebook sign-in"),
                                  ),
                                  _SocialIconButton(
                                    tooltip: "Continue with Apple",
                                    icon: FontAwesomeIcons.apple,
                                    onPressed: () =>
                                        _showNotImplemented("Apple sign-in"),
                                  ),
                                  _SocialIconButton(
                                    tooltip: "Continue with Discord",
                                    icon: FontAwesomeIcons.discord,
                                    onPressed: () =>
                                        _showNotImplemented("Discord sign-in"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "By creating an account, you confirm that you accept our ",
                                    style: bodyTextStyle.copyWith(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.55),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        _showNotImplemented("Terms of Use"),
                                    child: Text(
                                      "Terms of Use",
                                      style: linkTextStyle.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    " and ",
                                    style: bodyTextStyle.copyWith(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.55),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        _showNotImplemented("Privacy Policy"),
                                    child: Text(
                                      "Privacy Policy",
                                      style: linkTextStyle.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ".",
                                    style: bodyTextStyle.copyWith(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/login.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthSideBar extends StatelessWidget {
  final VoidCallback onClose;

  const _AuthSideBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Image.asset('assets/logo.png', height: 36, width: 32),
          const SizedBox(width: 10),
          Text(
            "Waiby",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: "Close",
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: Colors.white,
            splashRadius: 22,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

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
