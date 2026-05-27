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

    // ── Fade + scale (mirrors .fadeIn(800ms).scale(easeOutBack)) ──
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

    // ── Shimmer (mirrors .shimmer(delay:800ms, duration:1200ms)) ──
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start fade+scale immediately, then shimmer after 800ms delay
    _fadeScaleController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (mounted) _shimmerController.forward();
      });
    });

    // Navigate after 2500ms total — matches the original delay
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
    return Scaffold(
      backgroundColor: AppColors.primary, // matches colorScheme.primary
      body: Center(
        child: AnimatedBuilder(
          animation:
              Listenable.merge([_fadeScaleController, _shimmerController]),
          builder: (context, _) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: _ShimmerLogo(shimmerValue: _shimmerAnim.value),
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

  const _ShimmerLogo({required this.shimmerValue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base logo
          _AppLogo(),

          // Shimmer sweep overlay — only visible during shimmer phase
          if (shimmerValue > -1.0 && shimmerValue < 2.0)
            Positioned.fill(
              child: ClipRect(
                child: CustomPaint(
                  painter: _ShimmerPainter(
                    progress: shimmerValue,
                    shimmerColor: AppColors.accent.withOpacity(0.55),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── App logo — leaf + wordmark (matches AppLogo widget style) ─────────────────

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Leaf illustration
        CustomPaint(
          size: const Size(72, 72),
          painter: _LeafLogoPainter(),
        ),
        const SizedBox(height: 14),
        // Wordmark
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Yes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: 'Native',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '" Where Tradition Meets Wellness "',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
            fontStyle: FontStyle.italic,
            fontFamily: 'Poppins',
            letterSpacing: 0.3,
          ),
        ),
      ],
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

class _LeafLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Back leaf (semi-transparent)
    final backLeaf = Path();
    backLeaf.moveTo(w * 0.45, h * 0.85);
    backLeaf.cubicTo(
        w * 0.10, h * 0.70, w * 0.05, h * 0.30, w * 0.35, h * 0.10);
    backLeaf.cubicTo(
        w * 0.55, h * 0.00, w * 0.75, h * 0.15, w * 0.70, h * 0.45);
    backLeaf.cubicTo(
        w * 0.65, h * 0.65, w * 0.55, h * 0.80, w * 0.45, h * 0.85);
    backLeaf.close();
    canvas.drawPath(
      backLeaf,
      Paint()..color = Colors.white.withOpacity(0.45),
    );

    // Front leaf
    final frontLeaf = Path();
    frontLeaf.moveTo(w * 0.55, h * 0.90);
    frontLeaf.cubicTo(
        w * 0.20, h * 0.75, w * 0.15, h * 0.40, w * 0.40, h * 0.20);
    frontLeaf.cubicTo(
        w * 0.58, h * 0.08, w * 0.82, h * 0.22, w * 0.78, h * 0.52);
    frontLeaf.cubicTo(
        w * 0.74, h * 0.72, w * 0.65, h * 0.86, w * 0.55, h * 0.90);
    frontLeaf.close();
    canvas.drawPath(
      frontLeaf,
      Paint()..color = Colors.white,
    );

    // Center vein
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.55, h * 0.90)
        ..cubicTo(w * 0.50, h * 0.60, w * 0.48, h * 0.40, w * 0.55, h * 0.15),
      Paint()
        ..color = AppColors.primaryDark.withOpacity(0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
