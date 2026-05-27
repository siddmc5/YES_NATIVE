import 'package:flutter/material.dart';
import '../theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String subtitle;
  final bool? isPositive;
  final ThemeColors colors;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.subtitle,
    required this.isPositive,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (isPositive != null)
                Icon(
                  isPositive! ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isPositive! ? colors.success : colors.error,
                ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) => Opacity(
              opacity: val,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - val)),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: colors.textLight,
                  fontSize: 11,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isPositive == true
                  ? colors.success
                  : isPositive == false
                      ? colors.error
                      : colors.textLight,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
