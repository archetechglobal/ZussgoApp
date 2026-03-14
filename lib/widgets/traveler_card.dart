import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class TravelerCard extends StatelessWidget {
  final String id;
  final String name;
  final int age;
  final String destination;
  final String dates;
  final String travelStyle;
  final String avatar;
  final String matchPercent;
  final Color? accentColor;

  const TravelerCard({
    super.key,
    required this.id,
    required this.name,
    required this.age,
    required this.destination,
    required this.dates,
    required this.travelStyle,
    required this.avatar,
    required this.matchPercent,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? ZussGoTheme.amber;

    return GestureDetector(
      onTap: () => context.push('/traveler/$id'),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: ZussGoTheme.glassCard,
        child: Row(
          children: [
            // Monogram avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              alignment: Alignment.center,
              child: Text(
                name[0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Playfair Display',
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$name, $age', style: ZussGoTheme.labelBold),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ZussGoTheme.amber.withValues(alpha: 0.1),
                              ZussGoTheme.rose.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$matchPercent match',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ZussGoTheme.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('$destination • $dates', style: ZussGoTheme.bodySmall),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ZussGoTheme.bgCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ZussGoTheme.borderDefault),
                    ),
                    child: Text(
                      travelStyle,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ZussGoTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
