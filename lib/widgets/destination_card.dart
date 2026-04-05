import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class DestinationCard extends StatelessWidget {
  final String id;
  final String name;
  final String emoji;
  final int travelerCount;
  final Gradient gradient;
  final String? imageUrl;

  const DestinationCard({
    super.key,
    required this.id,
    required this.name,
    required this.emoji,
    required this.travelerCount,
    required this.gradient,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/destination/$id'),
      child: Container(
        width: 155,
        height: 195,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Network image background
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  imageUrl!,
                  width: 155,
                  height: 195,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.black12,
                      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38))),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black12,
                    child: Center(child: Icon(Icons.landscape_rounded, size: 40, color: Colors.white38)),
                  ),
                ),
              ),
            // Dark overlay gradient for text readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x99000000)],
                  stops: [0.3, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(color: context.colors.mint, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$travelerCount going',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9), fontFamily: 'Outfit'),
                        ),
                      ],
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