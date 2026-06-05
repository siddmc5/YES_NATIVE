import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../theme_provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Sign in with Google via Firebase Auth
      await AuthService.instance.signInWithGoogle();

      // 2. Register/fetch user from MongoDB via backend
      //    This creates the user document on first sign-in.
      await ApiService.instance.login(role: 'vendor');

      // 3. Navigate to main app
      if (mounted) {
        Navigator.of(context).pushReplacement(
          FadeSlideRoute(page: const MainShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().contains('cancelled')
              ? null
              : 'Sign in failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: colors.bannerGreen,
      body: Column(
        children: [
          // Green Header Section
          Container(
            color: colors.bannerGreen,
            width: double.infinity,
            child: SafeArea(
              bottom: false,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Card Section
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : colors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 1),
                      Text(
                        'Welcome',
                        style: GoogleFonts.poppins(
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to manage your orders and profile',
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          color: colors.textMedium,
                        ),
                      ),
                      const Spacer(flex: 2),

                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Google Sign-In Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _login,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: colors.border,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: colors.cardBackground,
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: colors.primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CustomPaint(
                                        painter: _GoogleLogoPainter(),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: colors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Google 'G' Painter ───────────────────────────────────────────────────────

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double s = size.width / 24.0;

    final redPath = Path()
      ..moveTo(12.0 * s, 5.38 * s)
      ..cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s, 16.21 * s, 7.02 * s)
      ..lineTo(19.36 * s, 3.87 * s)
      ..cubicTo(17.45 * s, 2.09 * s, 14.97 * s, 1.0 * s, 12.0 * s, 1.0 * s)
      ..cubicTo(7.7 * s, 1.0 * s, 3.99 * s, 3.47 * s, 2.18 * s, 7.06 * s)
      ..lineTo(5.84 * s, 9.9 * s)
      ..cubicTo(6.71 * s, 7.3 * s, 9.14 * s, 5.38 * s, 12.0 * s, 5.38 * s)
      ..close();
    canvas.drawPath(redPath, paint..color = const Color(0xFFEA4335));

    final yellowPath = Path()
      ..moveTo(5.84 * s, 14.09 * s)
      ..cubicTo(5.62 * s, 13.43 * s, 5.49 * s, 12.73 * s, 5.49 * s, 12.0 * s)
      ..cubicTo(5.49 * s, 11.27 * s, 5.62 * s, 10.57 * s, 5.84 * s, 9.91 * s)
      ..lineTo(2.18 * s, 7.06 * s)
      ..cubicTo(1.43 * s, 8.55 * s, 1.0 * s, 10.22 * s, 1.0 * s, 12.0 * s)
      ..cubicTo(1.0 * s, 13.78 * s, 1.43 * s, 15.45 * s, 2.18 * s, 16.94 * s)
      ..lineTo(5.03 * s, 14.72 * s)
      ..lineTo(5.84 * s, 14.09 * s)
      ..close();
    canvas.drawPath(yellowPath, paint..color = const Color(0xFFFBBC05));

    final greenPath = Path()
      ..moveTo(12.0 * s, 23.0 * s)
      ..cubicTo(14.97 * s, 23.0 * s, 17.46 * s, 22.02 * s, 19.28 * s, 20.34 * s)
      ..lineTo(15.71 * s, 17.57 * s)
      ..cubicTo(14.73 * s, 18.23 * s, 13.48 * s, 18.63 * s, 12.0 * s, 18.63 * s)
      ..cubicTo(9.14 * s, 18.63 * s, 6.71 * s, 16.7 * s, 5.84 * s, 14.1 * s)
      ..lineTo(2.18 * s, 16.94 * s)
      ..cubicTo(3.99 * s, 20.53 * s, 7.7 * s, 23.0 * s, 12.0 * s, 23.0 * s)
      ..close();
    canvas.drawPath(greenPath, paint..color = const Color(0xFF34A853));

    final bluePath = Path()
      ..moveTo(23.0 * s, 12.0 * s)
      ..cubicTo(23.0 * s, 11.21 * s, 22.93 * s, 10.46 * s, 22.81 * s, 9.73 * s)
      ..lineTo(12.0 * s, 9.73 * s)
      ..lineTo(12.0 * s, 14.24 * s)
      ..lineTo(18.18 * s, 14.24 * s)
      ..cubicTo(
          17.91 * s, 15.65 * s, 17.11 * s, 16.85 * s, 15.91 * s, 17.64 * s)
      ..lineTo(19.48 * s, 20.41 * s)
      ..cubicTo(21.57 * s, 18.41 * s, 23.0 * s, 15.42 * s, 23.0 * s, 12.0 * s)
      ..close();
    canvas.drawPath(bluePath, paint..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(_) => false;
}
