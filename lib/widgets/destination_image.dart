import 'package:flutter/material.dart';
import '../services/destination_images.dart';
import '../config/theme.dart';

class DestinationImage extends StatelessWidget {
  final Map<String, dynamic> destination;
  final double? width;
  final double? height;
  final BoxFit fit;

  const DestinationImage({
    super.key,
    required this.destination,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final slug = destination['slug']?.toString().toLowerCase() ?? '';
    final assetPath = DestinationImages.getAssetPath(slug);

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: ZussGoTheme.mutedBg(context),
      child: Center(
        child: Icon(
          Icons.landscape_rounded,
          size: 32,
          color: ZussGoTheme.mutedText(context).withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
