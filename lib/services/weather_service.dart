import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Open-Meteo: free, no API key, no rate limits
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Lat/Lng for Indian destinations
  static const Map<String, Map<String, double>> _coords = {
    'goa': {'lat': 15.4909, 'lng': 73.8278},
    'manali': {'lat': 32.2396, 'lng': 77.1887},
    'ladakh': {'lat': 34.1526, 'lng': 77.5771},
    'rishikesh': {'lat': 30.0869, 'lng': 78.2676},
    'jaipur': {'lat': 26.9124, 'lng': 75.7873},
    'kerala': {'lat': 10.8505, 'lng': 76.2711},
    'udaipur': {'lat': 24.5854, 'lng': 73.7125},
    'varanasi': {'lat': 25.3176, 'lng': 82.9739},
    'andaman': {'lat': 11.7401, 'lng': 92.6586},
    'kasol': {'lat': 32.0100, 'lng': 77.3150},
    'hampi': {'lat': 15.3350, 'lng': 76.4600},
    'spiti-valley': {'lat': 32.2460, 'lng': 78.0350},
    'dharmshala': {'lat': 32.2190, 'lng': 76.3234},
    'pondicherry': {'lat': 11.9416, 'lng': 79.8083},
    'munnar': {'lat': 10.0889, 'lng': 77.0595},
    'coorg': {'lat': 12.3375, 'lng': 75.8069},
    'shimla': {'lat': 31.1048, 'lng': 77.1734},
    'darjeeling': {'lat': 27.0360, 'lng': 88.2627},
    'pushkar': {'lat': 26.4897, 'lng': 74.5511},
    'gokarna': {'lat': 14.5479, 'lng': 74.3188},
  };

  // Cache to avoid repeated calls
  static final Map<String, _WeatherData> _cache = {};
  static const _cacheDuration = Duration(minutes: 30);

  /// Get current weather for a destination slug
  static Future<Map<String, dynamic>> getWeather(String slug) async {
    // Check cache
    if (_cache.containsKey(slug)) {
      final cached = _cache[slug]!;
      if (DateTime.now().difference(cached.fetchedAt) < _cacheDuration) {
        return cached.data;
      }
    }

    final coords = _coords[slug];
    if (coords == null) {
      return {'temp': 25, 'icon': '🌤️', 'condition': 'Pleasant', 'humidity': 60, 'windSpeed': 10};
    }

    try {
      final url = '$_baseUrl?latitude=${coords['lat']}&longitude=${coords['lng']}'
          '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
          '&timezone=Asia/Kolkata';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final current = json['current'];

        final temp = (current['temperature_2m'] as num).round();
        final humidity = (current['relative_humidity_2m'] as num).round();
        final windSpeed = (current['wind_speed_10m'] as num).round();
        final weatherCode = current['weather_code'] as int;

        final icon = _weatherIcon(weatherCode);
        final condition = _weatherCondition(weatherCode);

        final data = {
          'temp': temp,
          'icon': icon,
          'condition': condition,
          'humidity': humidity,
          'windSpeed': windSpeed,
          'weatherCode': weatherCode,
        };

        _cache[slug] = _WeatherData(data: data, fetchedAt: DateTime.now());
        return data;
      }
    } catch (e) {
      // Silently fall back to defaults
    }

    // Fallback
    return {'temp': 25, 'icon': '🌤️', 'condition': 'Pleasant', 'humidity': 60, 'windSpeed': 10};
  }

  /// Get weather for multiple destinations at once (batch)
  static Future<Map<String, Map<String, dynamic>>> getWeatherBatch(List<String> slugs) async {
    final results = <String, Map<String, dynamic>>{};

    // Fetch uncached ones
    final uncached = slugs.where((s) {
      if (_cache.containsKey(s) && DateTime.now().difference(_cache[s]!.fetchedAt) < _cacheDuration) {
        results[s] = _cache[s]!.data;
        return false;
      }
      return true;
    }).toList();

    // Batch: Open-Meteo doesn't support multi-location in one call, so we parallelize
    if (uncached.isNotEmpty) {
      final futures = uncached.map((s) async {
        results[s] = await getWeather(s);
      });
      await Future.wait(futures);
    }

    return results;
  }

  /// Check if coords exist for a slug
  static bool hasCoords(String slug) => _coords.containsKey(slug);

  /// Get coords for custom fetching
  static Map<String, double>? getCoords(String slug) => _coords[slug];

  // ─── WMO Weather Code Mappings ───

  static String _weatherIcon(int code) {
    if (code == 0) return '☀️';           // Clear sky
    if (code <= 3) return '⛅';            // Partly cloudy
    if (code <= 48) return '🌫️';           // Fog
    if (code <= 57) return '🌧️';           // Drizzle
    if (code <= 65) return '🌧️';           // Rain
    if (code <= 67) return '🌨️';           // Freezing rain
    if (code <= 77) return '❄️';           // Snow
    if (code <= 82) return '🌧️';           // Rain showers
    if (code <= 86) return '🌨️';           // Snow showers
    if (code >= 95) return '⛈️';           // Thunderstorm
    return '🌤️';
  }

  static String _weatherCondition(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 65) return 'Rainy';
    if (code <= 67) return 'Freezing rain';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Rain showers';
    if (code <= 86) return 'Snow showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Pleasant';
  }
}

class _WeatherData {
  final Map<String, dynamic> data;
  final DateTime fetchedAt;
  _WeatherData({required this.data, required this.fetchedAt});
}