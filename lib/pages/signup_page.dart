import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../widgets/auth/auth_page_layout.dart';

class SignupPage extends StatefulWidget {
  final AuthController auth;

  const SignupPage({super.key, required this.auth});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final bodyTextStyle = authBodyTextStyle();
    final linkTextStyle = authLinkTextStyle();

    return AuthPageLayout(
      onClose: () => context.go('/'),
      form: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign up',
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
              Text('Already have an account?', style: bodyTextStyle),
              InkWell(
                onTap: () => context.go('/login'),
                child: Text('Sign in', style: linkTextStyle),
              ),
            ],
          ),
          const SizedBox(height: 34),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: authFieldDecoration('Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: authFieldDecoration('Email'),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: authFieldDecoration('Password'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton(
              style: authPrimaryButtonStyle(),
              onPressed: () {
                widget.auth.login();
                context.go('/');
              },
              child: Text(
                'Create account',
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
    );
  }
}
