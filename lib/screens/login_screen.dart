import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../theme_provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'main_shell.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

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
              : 'Sign in failed: ${e.toString()}';
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
          // Top Half (Dark Green)
          Expanded(
            flex: 4,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Marquee of ingredients (always visible)
                  const Align(
                    alignment: Alignment.center,
                    child: IngredientsMarquee(),
                  ),

                  // Logo at Top Left
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24, top: 24),
                      child: Image.asset(
                        'assets/images/nevarkfoods.png',
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Half (Cream rounded container)
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF9F6F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
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
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your orders and profile',
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: colors.textMedium,
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.1),
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
            ).animate().slideY(
              begin: 1.0, 
              end: 0.0, 
              duration: const Duration(milliseconds: 800), 
              curve: Curves.easeOutQuart
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ingredients Marquee ───────────────────────────────────────────────────────

class IngredientsMarquee extends StatelessWidget {
  const IngredientsMarquee({super.key});

  @override
  Widget build(BuildContext context) {
    final images = [
      'assets/images/almonds_dates.png',
      'assets/images/black_rice.png',
      'assets/images/fresh_honey.png',
      'assets/images/raw_millets.png',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: [
          ...images.map(_buildIngredientCard),
          ...images.map(_buildIngredientCard),
          ...images.map(_buildIngredientCard),
        ],
      ).animate(onPlay: (controller) => controller.repeat())
       .slideX(begin: 0, end: -0.3333333, duration: const Duration(seconds: 15)),
    );
  }

  Widget _buildIngredientCard(String path) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white10,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        ),
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
