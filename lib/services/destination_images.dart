// lib/services/destination_images.dart
// Static destination images — no backend needed!
// Using Unsplash free images for each destination

class DestinationImages {
  // High quality images for each destination
  // These are free Unsplash images — no API key needed
  static const Map<String, String> images = {
    'goa': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800&q=80',
    'manali': 'https://images.unsplash.com/photo-1551884173-04724b7a6691?w=800&q=80',
    'ladakh': 'https://images.unsplash.com/photo-1506461883276-594a12b11cf3?w=800&q=80',
    'rishikesh': 'https://images.unsplash.com/photo-1598964340675-92db144063ef?w=800&q=80',
    'jaipur': 'https://images.unsplash.com/photo-1629731613204-1234c898c56e?w=800&q=80',
    'kerala': 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800&q=80',
    'udaipur': 'https://images.unsplash.com/photo-1632762391054-d31e97d3936a?w=800&q=80',
    'varanasi': 'https://images.unsplash.com/photo-1561361058-c24cecae35ca?w=800&q=80',
    'andaman': 'https://images.unsplash.com/photo-1590523277543-a94d2e4eb00b?w=1080&q=80',
    'andaman-nicobar': 'https://images.unsplash.com/photo-1590523277543-a94d2e4eb00b?w=1080&q=80',
    'andaman islands': 'https://images.unsplash.com/photo-1590523277543-a94d2e4eb00b?w=1080&q=80',
    'kasol': 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800&q=80',
    'hampi': 'https://images.unsplash.com/photo-1508913922312-3f19159937a0?w=800&q=80',
    'spiti-valley': 'https://images.unsplash.com/photo-1581793745862-99fde7fa73d2?w=800&q=80',
    'dharamshala': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
    'pondicherry': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
    'munnar': 'https://images.unsplash.com/photo-1516738901171-8eb4fc13bd20?w=800&q=80', // Fixed Munnar image
    'coorg': 'https://images.unsplash.com/photo-1634547466847-ba21d6091e3e?w=800&q=80',
    'shimla': 'https://images.unsplash.com/photo-1597074866923-dc0589150358?w=800&q=80',
    'darjeeling': 'https://images.unsplash.com/photo-1597074875475-39d673da118e?w=800&q=80',
    'pushkar': 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&q=80',
    'gokarna': 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=800&q=80',
  };

  /// Get image URL for a destination slug
  static String? getImage(String slug) {
    return images[slug.toLowerCase()];
  }

  /// Get image from destination data map (checks slug and name)
  static String? getImageFromData(Map<String, dynamic> destination) {
    final slug = destination['slug']?.toString().toLowerCase() ?? '';
    final name = destination['name']?.toString().toLowerCase() ?? '';
    
    // Direct matches
    if (images.containsKey(slug)) return images[slug];
    if (images.containsKey(name)) return images[name];
    
    // 2. Keyword/Partial match
    for (var entry in images.entries) {
      final key = entry.key;
      if (slug.contains(key) || name.contains(key) || key.contains(slug)) {
        return entry.value;
      }
    }
    
    // 3. Word-based fallback
    final words = [...slug.split(RegExp(r'[\s\-_]+')), ...name.split(RegExp(r'[\s\-_]+'))];
    for (var word in words) {
      if (word.length < 3) continue;
      if (images.containsKey(word)) return images[word];
    }
    
    return null;
  }
}