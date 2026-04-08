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
    'dharmshala': [3, 4, 5, 6, 9, 10],
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
        final now = DateTime.now();
        final rawEvents = List<Map<String, dynamic>>.from(r['data']);
        _eventsCache = rawEvents.where((e) {
          if (e['year'] == null || e['month'] == null) return true;
          final year = e['year'] as int;
          final month = e['month'] as int;
          if (year < now.year) return false;
          if (year == now.year && month < now.month) return false;
          return true;
        }).toList();
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
        final now = DateTime.now();
        final List<Map<String, dynamic>> rawEvents = List<Map<String, dynamic>>.from(r['data']);
        return rawEvents.where((e) {
          if (e['year'] == null || e['month'] == null) return true;
          final year = e['year'] as int;
          final month = e['month'] as int;
          if (year < now.year) return false;
          if (year == now.year && month < now.month) return false;
          return true;
        }).toList();
      }
    } catch (e) {
      // Fallback
    }
    return [];
  }

  // ─── MUST-VISIT PLACES (static — these don't change) ───
  static const Map<String, List<Map<String, String>>> mustVisit = {
    'goa': [
      {'image': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=500&q=80', 'name': 'Baga Beach', 'info': 'Nightlife hub'},
      {'image': 'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=500&q=80', 'name': 'Basilica of Bom Jesus', 'info': 'UNESCO site'},
      {'image': 'https://images.unsplash.com/photo-1620023640244-15f1717f9eb4?w=500&q=80', 'name': 'Dudhsagar Falls', 'info': '60 km'},
      {'image': 'https://images.unsplash.com/photo-1555315580-0a73da56fc39?w=500&q=80', 'name': 'Fort Aguada', 'info': '17th century'},
    ],
    'manali': [
      {'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&q=80', 'name': 'Solang Valley', 'info': 'Adventure sports'},
      {'image': 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=500&q=80', 'name': 'Rohtang Pass', 'info': '51 km'},
      {'image': 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=500&q=80', 'name': 'Old Manali', 'info': 'Cafes & vibes'},
    ],
    'ladakh': [
      {'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&q=80', 'name': 'Pangong Lake', 'info': '160 km from Leh'},
      {'image': 'https://images.unsplash.com/photo-1588636592209-1ba21245fa81?w=500&q=80', 'name': 'Khardung La', 'info': 'Highest motorable'},
      {'image': 'https://images.unsplash.com/photo-1582239459296-1502b489bc8e?w=500&q=80', 'name': 'Nubra Valley', 'info': 'Sand dunes'},
    ],
    'rishikesh': [
      {'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=500&q=80', 'name': 'Ram Jhula', 'info': 'Iconic bridge'},
      {'image': 'https://images.unsplash.com/photo-1610427845353-8b77626c04f4?w=500&q=80', 'name': 'River Rafting', 'info': 'Grade 3-4'},
      {'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&q=80', 'name': 'Beatles Ashram', 'info': 'Heritage'},
    ],
    'jaipur': [
      {'image': 'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=500&q=80', 'name': 'Amber Fort', 'info': 'Hilltop palace'},
      {'image': 'https://images.unsplash.com/photo-1561053720-76cd73ff22c3?w=500&q=80', 'name': 'Hawa Mahal', 'info': 'Palace of Winds'},
      {'image': 'https://images.unsplash.com/photo-1581457199201-38e530931215?w=500&q=80', 'name': 'City Palace', 'info': 'Royal residence'},
    ],
    'kerala': [
      {'image': 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=500&q=80', 'name': 'Alleppey Backwaters', 'info': 'Houseboat stays'},
      {'image': 'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?w=500&q=80', 'name': 'Munnar Tea Gardens', 'info': 'Hill station'},
      {'image': 'https://images.unsplash.com/photo-1620023640244-15f1717f9eb4?w=500&q=80', 'name': 'Thekkady', 'info': 'Wildlife sanctuary'},
    ],
    'udaipur': [
      {'image': 'https://images.unsplash.com/photo-1632762391054-d31e97d3936a?w=500&q=80', 'name': 'City Palace', 'info': 'Lakeside palace'},
      {'image': 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=500&q=80', 'name': 'Pichola Lake', 'info': 'Sunset boating'},
      {'image': 'https://images.unsplash.com/photo-1590856029826-c7a73142bbf1?w=500&q=80', 'name': 'Saheliyon-ki-Bari', 'info': 'Royal garden'},
    ],
    'varanasi': [
      {'image': 'https://images.unsplash.com/photo-1561361058-c24cecae35ca?w=500&q=80', 'name': 'Dashashwamedh Ghat', 'info': 'Evening Aarti'},
      {'image': 'https://images.unsplash.com/photo-1598964340675-92db144063ef?w=500&q=80', 'name': 'Sarnath', 'info': 'Buddhist site'},
      {'image': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=500&q=80', 'name': 'Kashi Vishwanath', 'info': 'Golden Temple'},
    ],
    'andaman': [
      {'image': 'https://images.unsplash.com/photo-1589136142558-94675c602477?w=800&q=80', 'name': 'Radhanagar Beach', 'info': 'Iconic white sand'},
      {'image': 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=800&q=80', 'name': 'Cellular Jail', 'info': 'National memorial'},
      {'image': 'https://images.unsplash.com/photo-1620152536344-98cd04b81eca?w=800&q=80', 'name': 'Elephant Beach', 'info': 'Snorkeling & corals'},
    ],
    'kasol': [
      {'image': 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=500&q=80', 'name': 'Parvati River', 'info': 'Scenic riverside'},
      {'image': 'https://images.unsplash.com/photo-1551884173-04724b7a6691?w=500&q=80', 'name': 'Kheerganga Trek', 'info': 'Hot springs'},
      {'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&q=80', 'name': 'Tosh Village', 'info': 'Hippie vibes'},
    ],
    'hampi': [
      {'image': 'https://images.unsplash.com/photo-1508913922312-3f19159937a0?w=500&q=80', 'name': 'Virupaksha Temple', 'info': 'Ancient heritage'},
      {'image': 'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=500&q=80', 'name': 'Stone Chariot', 'info': 'Vittala Temple'},
      {'image': 'https://images.unsplash.com/photo-1590856029826-c7a73142bbf1?w=500&q=80', 'name': 'Matanga Hill', 'info': 'Sunrise views'},
    ],
    'spiti-valley': [
      {'image': 'https://images.unsplash.com/photo-1581793745862-99fde7fa73d2?w=500&q=80', 'name': 'Key Monastery', 'info': 'Cliffside temple'},
      {'image': 'https://images.unsplash.com/photo-1506461883276-594a12b11cf3?w=500&q=80', 'name': 'Chandratal Lake', 'info': 'Moon lake'},
      {'image': 'https://images.unsplash.com/photo-1551884173-04724b7a6691?w=500&q=80', 'name': 'Kaza', 'info': 'Main hub'},
    ],
    'dharmshala': [
      {'image': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=500&q=80', 'name': 'McLeod Ganj', 'info': 'Little Lhasa'},
      {'image': 'https://images.unsplash.com/photo-1597074866923-dc0589150358?w=500&q=80', 'name': 'HPCA Stadium', 'info': 'Cricket with views'},
      {'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&q=80', 'name': 'Triund Trek', 'info': 'Easy day hike'},
    ],
    'pondicherry': [
      {'image': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=500&q=80', 'name': 'French Quarter', 'info': 'Colorful streets'},
      {'image': 'https://images.unsplash.com/photo-1508913922312-3f19159937a0?w=500&q=80', 'name': 'Auroville', 'info': 'Peace community'},
      {'image': 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=500&q=80', 'name': 'Rock Beach', 'info': 'Promenade walk'},
    ],
    'munnar': [
      {'image': 'https://images.unsplash.com/photo-1516738901171-8eb4fc13bd20?w=500&q=80', 'name': 'Tea Museum', 'info': 'History of tea'},
      {'image': 'https://images.unsplash.com/photo-1602152536344-98cd04b81eca?w=500&q=80', 'name': 'Eravikulam Park', 'info': 'Nilgiri Tahr'},
      {'image': 'https://images.unsplash.com/photo-1506461883276-594a12b11cf3?w=500&q=80', 'name': 'Mattupetty Dam', 'info': 'Lake views'},
    ],
    'coorg': [
      {'image': 'https://images.unsplash.com/photo-1634547466847-ba21d6091e3e?w=500&q=80', 'name': 'Abbey Falls', 'info': 'Coffee estates'},
      {'image': 'https://images.unsplash.com/photo-1580637354101-729469599d6d?w=500&q=80', 'name': 'Raja Seat', 'info': 'Golden views'},
      {'image': 'https://images.unsplash.com/photo-1551884173-04724b7a6691?w=500&q=80', 'name': 'Golden Temple', 'info': 'Bylakuppe Tibetan'},
    ],
    'shimla': [
      {'image': 'https://images.unsplash.com/photo-1597074866923-dc0589150358?w=500&q=80', 'name': 'The Ridge', 'info': 'Town center'},
      {'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&q=80', 'name': 'Jakhu Temple', 'info': 'Monkey god'},
      {'image': 'https://images.unsplash.com/photo-1595815771614-ade9d652a65d?w=500&q=80', 'name': 'Kufri', 'info': 'Snow fun'},
    ],
    'darjeeling': [
      {'image': 'https://images.unsplash.com/photo-1597074875475-39d673da118e?w=500&q=80', 'name': 'Tiger Hill', 'info': 'Kanchenjunga view'},
      {'image': 'https://images.unsplash.com/photo-1516738901171-8eb4fc13bd20?w=500&q=80', 'name': 'Toy Train', 'info': 'Heritage rail'},
      {'image': 'https://images.unsplash.com/photo-1602152536344-98cd04b81eca?w=500&q=80', 'name': 'Batasia Loop', 'info': 'War memorial'},
    ],
    'pushkar': [
      {'image': 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=500&q=80', 'name': 'Brahma Temple', 'info': 'Only one in world'},
      {'image': 'https://images.unsplash.com/photo-1561053720-76cd73ff22c3?w=500&q=80', 'name': 'Pushkar Lake', 'info': 'Holy ghats'},
      {'image': 'https://images.unsplash.com/photo-1581457199201-38e530931215?w=500&q=80', 'name': 'Savitri Temple', 'info': 'Hilltop view'},
    ],
    'gokarna': [
      {'image': 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=500&q=80', 'name': 'Om Beach', 'info': 'Shape of Om'},
      {'image': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=500&q=80', 'name': 'Half Moon Beach', 'info': 'Secluded trek'},
      {'image': 'https://images.unsplash.com/photo-1555315580-0a73da56fc39?w=500&q=80', 'name': 'Mahabaleshwar', 'info': 'Temple town'},
    ],
  };

  static List<Map<String, String>> getMustVisit(String slug) {
    return mustVisit[slug] ?? [
      {'name': 'Explore', 'info': 'Discover hidden gems'},
    ];
  }
}