import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _moveLogo = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() { _moveLogo = true; });
    });
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const LoginScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bannerGreen,
      body: SafeArea(
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          alignment: _moveLogo ? Alignment.topLeft : Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 24.0),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              scale: _moveLogo ? 0.6 : 1.0,
              child: Image.asset(
                'assets/images/nevarkfoods.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
