import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/destination_images.dart';

class ShareTripCard extends StatelessWidget {
  final String destinationName;
  final String? destinationSlug;
  final String dates;
  final String? budget;
  final String userName;
  final Map<String, dynamic>? destinationData;

  const ShareTripCard({
    super.key,
    required this.destinationName,
    this.destinationSlug,
    required this.dates,
    this.budget,
    required this.userName,
    this.destinationData,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = destinationData != null 
        ? DestinationImages.getImageFromData(destinationData!) 
        : null;

    return Container(
      width: 320,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (imageUrl != null)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
                  ),
                ),
              ),

            // Dark Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo / Top section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'ZUSSGO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Main Heading
                  const Text(
                    "I'M GOING TO",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destinationName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 38,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Trip Details
                  _DetailRow(icon: Icons.calendar_today_rounded, label: dates),
                  if (budget != null) ...[
                    const SizedBox(height: 12),
                    _DetailRow(icon: Icons.account_balance_wallet_rounded, label: '$budget Trip'),
                  ],
                  
                  const SizedBox(height: 48),
                  
                  // Footer
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ZussGoTheme.lavender.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'Z',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Playfair Display',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Find me on ZussGo',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: ZussGoTheme.lavender.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
