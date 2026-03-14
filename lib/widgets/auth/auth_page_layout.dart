import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const authBackgroundColor = Color(0xFF0D1220);
const authAccentBlue = Color(0xFF2F88FF);

TextStyle authBodyTextStyle() {
  return GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white.withValues(alpha: 0.84),
  );
}

TextStyle authLinkTextStyle() {
  return GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: authAccentBlue,
    decoration: TextDecoration.underline,
    decorationColor: authAccentBlue,
  );
}

InputDecoration authFieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.06),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: authAccentBlue, width: 1.4),
    ),
  );
}

ButtonStyle authPrimaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: authAccentBlue,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
  );
}

class AuthPageLayout extends StatelessWidget {
  final Widget form;
  final VoidCallback onClose;

  const AuthPageLayout({super.key, required this.form, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: authBackgroundColor,
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: SafeArea(
              child: Column(
                children: [
                  AuthHeaderBar(onClose: onClose),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 20,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: form,
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
                  image: AssetImage('assets/login.png'),
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

class AuthHeaderBar extends StatelessWidget {
  final VoidCallback onClose;

  const AuthHeaderBar({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Image.asset('assets/logo.png', height: 36, width: 32),
            const SizedBox(width: 10),
            Text(
              'Waiby',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Close',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              color: Colors.white,
              splashRadius: 22,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
