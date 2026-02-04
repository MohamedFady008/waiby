import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';

class SignupPage extends StatefulWidget {
  final AuthController auth;

  const SignupPage({super.key, required this.auth});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sign up",
                                style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: bodyTextStyle,
                                  ),
                                  InkWell(
                                    onTap: () => context.go('/login'),
                                    child: Text(
                                      "Sign in",
                                      style: linkTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 34),
                              TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration("Name"),
                              ),
                              const SizedBox(height: 16),
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
                              const SizedBox(height: 18),
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
                                    "Create account",
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
              decoration: const BoxDecoration(
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
