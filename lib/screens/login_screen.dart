import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        FadeSlideRoute(page: const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bannerGreen,
      body: Column(
        children: [
          // Green Header Section
          Container(
            color: AppColors.bannerGreen,
            width: double.infinity,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(72, 72),
                        painter: _LeafLogoPainter(),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Yes',
                                style: GoogleFonts.caveat(
                                  fontSize: 54,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  height: 0.9,
                                ),
                              ),
                              Text(
                                'Native',
                                style: GoogleFonts.caveat(
                                  fontSize: 54,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 0.9,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '" Where Tradition Meets Wellness "',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 1.2,
                            width: 188,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Functional Superfoods',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 42),
                ],
              ),
            ),
          ),

          // White Card Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: GoogleFonts.poppins(
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to manage your orders and profile',
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Google Sign-In Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _login,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
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
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
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

// ── Leaf Logo Painter ────────────────────────────────────────────────────────

class _LeafLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Back-right leaf (most transparent)
    final leaf3 = Path();
    leaf3.moveTo(w * 0.60, h * 0.88);
    leaf3.cubicTo(w * 0.30, h * 0.72, w * 0.28, h * 0.35, w * 0.52, h * 0.12);
    leaf3.cubicTo(w * 0.72, h * 0.00, w * 0.92, h * 0.18, w * 0.88, h * 0.50);
    leaf3.cubicTo(w * 0.84, h * 0.72, w * 0.72, h * 0.85, w * 0.60, h * 0.88);
    leaf3.close();
    canvas.drawPath(leaf3, Paint()..color = Colors.white.withOpacity(0.28));

    // Back-left vein
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.60, h * 0.88)
        ..cubicTo(w * 0.58, h * 0.58, w * 0.60, h * 0.34, w * 0.66, h * 0.08),
      Paint()
        ..color = AppColors.primaryDark.withOpacity(0.15)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Middle leaf (semi-transparent)
    final leaf2 = Path();
    leaf2.moveTo(w * 0.48, h * 0.92);
    leaf2.cubicTo(w * 0.12, h * 0.76, w * 0.08, h * 0.36, w * 0.36, h * 0.12);
    leaf2.cubicTo(w * 0.56, h * 0.00, w * 0.80, h * 0.18, w * 0.75, h * 0.50);
    leaf2.cubicTo(w * 0.70, h * 0.72, w * 0.58, h * 0.88, w * 0.48, h * 0.92);
    leaf2.close();
    canvas.drawPath(leaf2, Paint()..color = Colors.white.withOpacity(0.55));

    // Middle vein
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.48, h * 0.92)
        ..cubicTo(w * 0.44, h * 0.62, w * 0.44, h * 0.36, w * 0.50, h * 0.08),
      Paint()
        ..color = AppColors.primaryDark.withOpacity(0.18)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Front leaf (fully opaque)
    final frontLeaf = Path();
    frontLeaf.moveTo(w * 0.38, h * 0.94);
    frontLeaf.cubicTo(
        w * 0.04, h * 0.78, w * 0.00, h * 0.38, w * 0.26, h * 0.14);
    frontLeaf.cubicTo(
        w * 0.46, h * 0.00, w * 0.72, h * 0.16, w * 0.66, h * 0.50);
    frontLeaf.cubicTo(
        w * 0.60, h * 0.74, w * 0.50, h * 0.90, w * 0.38, h * 0.94);
    frontLeaf.close();
    canvas.drawPath(frontLeaf, Paint()..color = Colors.white);

    // Front vein
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.38, h * 0.94)
        ..cubicTo(w * 0.34, h * 0.64, w * 0.36, h * 0.38, w * 0.42, h * 0.10),
      Paint()
        ..color = AppColors.primaryDark.withOpacity(0.28)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
