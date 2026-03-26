// lib/services/destination_data.dart
// Dynamic data service — fetches real weather from Open-Meteo + events from backend
// Peak season data is kept static (based on climate patterns that don't change)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_service.dart';
import 'api_service.dart';

class DestinationData {
  // ─── PEAK SEASON (climate-based, doesn't change year to year) ───
  static const Map<String, List<int>> peakMonths = {
    'goa': [11, 12, 1, 2],
    'manali': [12, 1, 2, 3, 5, 6],
    'ladakh': [6, 7, 8, 9],
    'rishikesh': [10, 11, 12, 1, 2, 3],
    'jaipur': [11, 12, 1, 2],
    'kerala': [10, 11, 12, 1, 2, 3],
    'udaipur': [10, 11, 12, 1, 2, 3],
    'varanasi': [11, 12, 1, 2],
    'andaman': [12, 1, 2, 3, 4],
    'kasol': [3, 4, 5, 6, 9, 10],
    'hampi': [10, 11, 12, 1, 2],
    'spiti-valley': [6, 7, 8, 9],
    'dharamshala': [3, 4, 5, 6, 9, 10],
    'pondicherry': [10, 11, 12, 1, 2, 3],
    'munnar': [10, 11, 12, 1, 2, 3],
    'coorg': [10, 11, 12, 1, 2, 3],
    'shimla': [12, 1, 2, 5, 6],
    'darjeeling': [3, 4, 5, 10, 11],
    'pushkar': [10, 11, 12, 1, 2],
    'gokarna': [11, 12, 1, 2, 3],
  };

  /// Is this destination peak right now or in the next 2 months?
  static bool isPeakNow(String slug) {
    final now = DateTime.now().month;
    final months = peakMonths[slug] ?? [];
    return months.contains(now) || months.contains((now % 12) + 1) || months.contains(((now + 1) % 12) + 1);
  }

  static String getPeakLabel(String slug) {
    final now = DateTime.now().month;
    final months = peakMonths[slug] ?? [];
    if (months.contains(now)) return 'Perfect right now!';
    if (months.contains((now % 12) + 1)) return 'Peak next month!';
    if (months.contains(((now + 1) % 12) + 1)) return 'Peak in 2 months!';
    return 'Off-season';
  }

  static String getBestMonthsLabel(String slug) {
    final months = peakMonths[slug];
    if (months == null || months.isEmpty) return 'Year-round';
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final sorted = List<int>.from(months)..sort();
    if (sorted.length <= 2) return sorted.map((m) => names[m]).join('-');
    return '${names[sorted.first]}-${names[sorted.last]}';
  }

  static List<String> getPeakDestinations() {
    final now = DateTime.now().month;
    final next1 = (now % 12) + 1;
    final next2 = ((now + 1) % 12) + 1;
    return peakMonths.entries
        .where((e) => e.value.contains(now) || e.value.contains(next1) || e.value.contains(next2))
        .map((e) => e.key)
        .toList();
  }

  // ─── REAL-TIME WEATHER (from Open-Meteo API) ───

  /// Get live weather for a destination — returns {temp, icon, condition}
  static Future<Map<String, dynamic>> getWeather(String slug) async {
    return await WeatherService.getWeather(slug);
  }

  /// Batch fetch weather for multiple destinations
  static Future<Map<String, Map<String, dynamic>>> getWeatherBatch(List<String> slugs) async {
    return await WeatherService.getWeatherBatch(slugs);
  }

  // ─── EVENTS FROM BACKEND ───

  // Cache events for 10 minutes
  static List<Map<String, dynamic>>? _eventsCache;
  static DateTime? _eventsCacheTime;

  /// Get upcoming events from backend API
  static Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    // Check cache
    if (_eventsCache != null && _eventsCacheTime != null &&
        DateTime.now().difference(_eventsCacheTime!) < const Duration(minutes: 10)) {
      return _eventsCache!;
    }

    try {
      final r = await ApiService.getEvents();
      if (r['success'] == true && r['data'] != null) {
        _eventsCache = List<Map<String, dynamic>>.from(r['data']);
        _eventsCacheTime = DateTime.now();
        return _eventsCache!;
      }
    } catch (e) {
      // Fall back to cache or empty
    }
    return _eventsCache ?? [];
  }

  /// Get events for a specific destination from backend
  static Future<List<Map<String, dynamic>>> getEventsForDestination(String slug) async {
    try {
      final r = await ApiService.getEventsForDestination(slug);
      if (r['success'] == true && r['data'] != null) {
        return List<Map<String, dynamic>>.from(r['data']);
      }
    } catch (e) {
      // Fallback
    }
    return [];
  }

  // ─── MUST-VISIT PLACES (static — these don't change) ───
  static const Map<String, List<Map<String, String>>> mustVisit = {
    'goa': [
      {'emoji': '🏖️', 'name': 'Baga Beach', 'info': 'Nightlife hub'},
      {'emoji': '⛪', 'name': 'Basilica of Bom Jesus', 'info': 'UNESCO site'},
      {'emoji': '🌊', 'name': 'Dudhsagar Falls', 'info': '60 km'},
      {'emoji': '🏛️', 'name': 'Fort Aguada', 'info': '17th century'},
      {'emoji': '🌅', 'name': 'Palolem Beach', 'info': 'Serene south'},
    ],
    'manali': [
      {'emoji': '🏔️', 'name': 'Solang Valley', 'info': 'Adventure sports'},
      {'emoji': '🌊', 'name': 'Jogini Falls', 'info': '3 km trek'},
      {'emoji': '🏔️', 'name': 'Rohtang Pass', 'info': '51 km'},
      {'emoji': '🛕', 'name': 'Hadimba Temple', 'info': 'Ancient'},
      {'emoji': '🌲', 'name': 'Old Manali', 'info': 'Cafes & vibes'},
    ],
    'ladakh': [
      {'emoji': '🏞️', 'name': 'Pangong Lake', 'info': '160 km from Leh'},
      {'emoji': '🏔️', 'name': 'Khardung La', 'info': 'Highest motorable'},
      {'emoji': '🛕', 'name': 'Thiksey Monastery', 'info': '19 km'},
      {'emoji': '🏜️', 'name': 'Nubra Valley', 'info': 'Sand dunes'},
      {'emoji': '🏍️', 'name': 'Magnetic Hill', 'info': 'Optical illusion'},
    ],
    'rishikesh': [
      {'emoji': '🌉', 'name': 'Ram Jhula', 'info': 'Iconic bridge'},
      {'emoji': '🌊', 'name': 'River Rafting', 'info': 'Grade 3-4'},
      {'emoji': '🧘', 'name': 'Beatles Ashram', 'info': 'Heritage'},
      {'emoji': '⛰️', 'name': 'Triveni Ghat', 'info': 'Evening Aarti'},
      {'emoji': '🏕️', 'name': 'Shivpuri Camping', 'info': '16 km'},
    ],
    'jaipur': [
      {'emoji': '🏰', 'name': 'Amber Fort', 'info': 'Hilltop palace'},
      {'emoji': '🌬️', 'name': 'Hawa Mahal', 'info': 'Palace of Winds'},
      {'emoji': '🏛️', 'name': 'City Palace', 'info': 'Royal residence'},
      {'emoji': '📐', 'name': 'Jantar Mantar', 'info': 'Observatory'},
      {'emoji': '🐅', 'name': 'Nahargarh Fort', 'info': 'Sunset views'},
    ],
    'kerala': [
      {'emoji': '🛶', 'name': 'Alleppey Backwaters', 'info': 'Houseboats'},
      {'emoji': '🌿', 'name': 'Munnar Tea Gardens', 'info': 'Hill station'},
      {'emoji': '🏖️', 'name': 'Varkala Beach', 'info': 'Cliff views'},
      {'emoji': '🐘', 'name': 'Periyar Wildlife', 'info': 'Sanctuary'},
      {'emoji': '🏛️', 'name': 'Fort Kochi', 'info': 'Colonial charm'},
    ],
    'varanasi': [
      {'emoji': '🛕', 'name': 'Dashashwamedh Ghat', 'info': 'Evening Aarti'},
      {'emoji': '🌅', 'name': 'Sunrise Boat Ride', 'info': 'Ganges'},
      {'emoji': '🕉️', 'name': 'Kashi Vishwanath', 'info': 'Ancient temple'},
      {'emoji': '🏛️', 'name': 'Sarnath', 'info': '10 km, Buddhist'},
      {'emoji': '🎨', 'name': 'Silk Weaving', 'info': 'Banarasi silk'},
    ],
    'udaipur': [
      {'emoji': '🏰', 'name': 'City Palace', 'info': 'Lakeside palace'},
      {'emoji': '🌊', 'name': 'Lake Pichola', 'info': 'Boat ride'},
      {'emoji': '🏛️', 'name': 'Jag Mandir', 'info': 'Island palace'},
      {'emoji': '🎨', 'name': 'Saheliyon ki Bari', 'info': 'Garden'},
    ],
  };

  static List<Map<String, String>> getMustVisit(String slug) {
    return mustVisit[slug] ?? [
      {'emoji': '📍', 'name': 'Explore', 'info': 'Discover hidden gems'},
    ];
  }
}