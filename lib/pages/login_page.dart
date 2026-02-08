import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../widgets/auth/auth_page_layout.dart';

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
            'Sign in',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text("If you don't have an account", style: bodyTextStyle),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Text('You can', style: bodyTextStyle),
              InkWell(
                onTap: () => context.go('/signup'),
                child: Text('Register here', style: linkTextStyle),
              ),
            ],
          ),
          const SizedBox(height: 34),
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
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final remember = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: authAccentBlue,
                    onChanged: (value) =>
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
                onPressed: () => _showNotImplemented('Forgot password'),
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
          Row(
            children: [
              Expanded(
                child: Divider(color: Colors.white.withValues(alpha: 0.15)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: bodyTextStyle.copyWith(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: Colors.white.withValues(alpha: 0.15)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _SocialIconButton(
                tooltip: 'Continue with Google',
                icon: FontAwesomeIcons.google,
                onPressed: () => _showNotImplemented('Google sign-in'),
              ),
              _SocialIconButton(
                tooltip: 'Continue with Facebook',
                icon: FontAwesomeIcons.facebookF,
                onPressed: () => _showNotImplemented('Facebook sign-in'),
              ),
              _SocialIconButton(
                tooltip: 'Continue with Apple',
                icon: FontAwesomeIcons.apple,
                onPressed: () => _showNotImplemented('Apple sign-in'),
              ),
              _SocialIconButton(
                tooltip: 'Continue with Discord',
                icon: FontAwesomeIcons.discord,
                onPressed: () => _showNotImplemented('Discord sign-in'),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                  color: Colors.white.withValues(alpha: 0.55),
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
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
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
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          onTap: onPressed,
          child: Ink(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Center(child: FaIcon(icon, size: 20, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
