import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Fade + scale controller
  late final AnimationController _fadeScaleController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  // Shimmer controller
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _fadeScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeScaleController,
      curve: Curves.easeIn,
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeScaleController,
        curve: Curves.easeOutBack,
      ),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _fadeScaleController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (mounted) _shimmerController.forward();
      });
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          FadeSlideRoute(page: const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeScaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation:
              Listenable.merge([_fadeScaleController, _shimmerController]),
          builder: (context, _) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: _ShimmerLogo(
                  shimmerValue: _shimmerAnim.value,
                  accentColor: colors.accent,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Logo with shimmer overlay ─────────────────────────────────────────────────

class _ShimmerLogo extends StatelessWidget {
  final double shimmerValue;
  final Color accentColor;

  const _ShimmerLogo({
    required this.shimmerValue,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base logo
          _AppLogo(),

          // Shimmer sweep overlay
          if (shimmerValue > -1.0 && shimmerValue < 2.0)
            Positioned.fill(
              child: ClipRect(
                child: CustomPaint(
                  painter: _ShimmerPainter(
                    progress: shimmerValue,
                    shimmerColor: accentColor.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── App logo — app icon image ────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: 140,
    );
  }
}

// ── Shimmer sweep painter ─────────────────────────────────────────────────────

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color shimmerColor;

  _ShimmerPainter({required this.progress, required this.shimmerColor});

  @override
  void paint(Canvas canvas, Size size) {
    final shimmerWidth = size.width * 0.45;
    final left = size.width * progress - shimmerWidth;

    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        shimmerColor,
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTWH(left, 0, shimmerWidth, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.srcATop;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}

// ── Leaf logo painter ─────────────────────────────────────────────────────────
