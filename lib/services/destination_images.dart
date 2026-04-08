// lib/services/destination_images.dart
// Static destination images — no backend needed!

class DestinationImages {
  /// Get asset path for a destination slug
  static String getAssetPath(String slug) {
    String s = slug.toLowerCase().trim();
    
    // Handle variations/misspellings
    if (s.contains('andaman')) s = 'andaman';
    if (s.contains('dharm') || s.contains('dharam')) s = 'dharmshala';
    if (s.contains('spiti')) s = 'spiti-valley';
    if (s.contains('kerala') || s.contains('karala') || s.contains('karel')) s = 'kerala';
    
    // Replace spaces/underscores with hyphens for consistency
    s = s.replaceAll(RegExp(r'[\s_]+'), '-');
    
    return 'assets/images/destinations/$s.jpg';
  }
}