import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class ApiService {

  // ─── DESTINATIONS ───

  static Future<Map<String, dynamic>> getDestinations() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.destinations), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> searchDestinations(String query) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.destinationSearch}?q=$query"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getDestinationBySlug(String slug, {String? userId}) async {
    try {
      final query = userId != null ? "?userId=$userId" : "";
      final response = await http.get(Uri.parse("${ApiConfig.destinationBySlug(slug)}$query"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── TRIPS ───

  static Future<Map<String, dynamic>> createTrip({
    required String userId,
    required String destinationId,
    required String startDate,
    required String endDate,
    String? budget,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.trips),
        headers: _headers(),
        body: jsonEncode({
          "userId": userId,
          "destinationId": destinationId,
          "startDate": startDate,
          "endDate": endDate,
          if (budget != null) "budget": budget,
          if (notes != null) "notes": notes,
        }),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getMyTrips(String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.trips}?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getTripTravelers(String tripId, String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.tripTravelers(tripId)}?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> deleteTrip(String tripId, String userId) async {
    try {
      final response = await http.delete(Uri.parse("${ApiConfig.tripById(tripId)}?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── MATCH REQUESTS ───

  static Future<Map<String, dynamic>> sendMatchRequest({
    required String userId,
    required String receiverId,
    String? tripId,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.matchRequests),
        headers: _headers(),
        body: jsonEncode({
          "userId": userId,
          "receiverId": receiverId,
          if (tripId != null) "tripId": tripId,
          if (message != null) "message": message,
        }),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getPendingRequests(String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.matchRequestsPending}?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getSentRequests(String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.matchRequestsSent}?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> acceptMatchRequest(String requestId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.matchRequestAccept(requestId)),
        headers: _headers(),
        body: jsonEncode({"userId": userId}),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> rejectMatchRequest(String requestId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.matchRequestReject(requestId)),
        headers: _headers(),
        body: jsonEncode({"userId": userId}),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── MATCHES ───

  static Future<Map<String, dynamic>> getMatches(String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.matches}?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── CONVERSATIONS ───

  static Future<Map<String, dynamic>> getConversations(String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.conversations}?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── MESSAGES ───

  static Future<Map<String, dynamic>> getMessages(String conversationId, String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.messagesByConversation(conversationId)}?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String userId,
    required String conversationId,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.messages),
        headers: _headers(),
        body: jsonEncode({
          "userId": userId,
          "conversationId": conversationId,
          "content": content,
        }),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getUnreadCount(String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.messagesUnread}?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── RATINGS ───

  static Future<Map<String, dynamic>> createRating({
    required String userId,
    required String ratedId,
    required String tripId,
    required int score,
    String? review,
    List<String>? moodTags,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.ratings),
        headers: _headers(),
        body: jsonEncode({
          "userId": userId,
          "ratedId": ratedId,
          "tripId": tripId,
          "score": score,
          if (review != null) "review": review,
          if (moodTags != null) "moodTags": moodTags,
        }),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── BLOCKS ───

  static Future<Map<String, dynamic>> blockUser(String userId, String blockedId, {String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.blocks),
        headers: _headers(),
        body: jsonEncode({
          "userId": userId,
          "blockedId": blockedId,
          if (reason != null) "reason": reason,
        }),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── REPORTS ───

  static Future<Map<String, dynamic>> reportUser({
    required String userId,
    required String reportedId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.reports),
        headers: _headers(),
        body: jsonEncode({
          "userId": userId,
          "reportedId": reportedId,
          "reason": reason,
          if (description != null) "description": description,
        }),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── HELPERS ───

  static Map<String, String> _headers() => {"Content-Type": "application/json"};

  static Map<String, dynamic> _parse(http.Response response) {
    final data = jsonDecode(response.body);
    return {
      "success": data["success"] ?? false,
      "message": data["message"] ?? "Something went wrong",
      "data": data["data"],
      "statusCode": response.statusCode,
    };
  }

  static Future<Map<String, dynamic>> getUserProfile(String travelerId, {String? currentUserId}) async {
    try {
      final query = currentUserId != null ? "?userId=$currentUserId" : "";
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/auth/users/$travelerId$query"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> submitRating({
    required String raterId,
    required String rateeId,
    required String tripId,
    required int score,
    String? review,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/ratings"),
        headers: _headers(),
        body: jsonEncode({
          "raterId": raterId,
          "rateeId": rateeId,
          "tripId": tripId,
          "score": score,
          if (review != null && review.isNotEmpty) "review": review,
        }),
      );
      return _parse(response);
    } catch (e) {
      return _error();
    }
  }

  static Map<String, dynamic> _error() {
    return {
      "success": false,
      "message": "Could not connect to server",
      "data": null,
      "statusCode": 0,
    };
  }

  // ─── EVENTS ───

  static Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/events"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getEventsForDestination(String slug) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/events?destination=$slug"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── GROUPS ───

  static Future<Map<String, dynamic>> getGroups(String destinationId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/groups?destinationId=$destinationId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getMyGroups(String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/groups/my?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> createGroup(Map<String, dynamic> data) async {
    try {
      final response = await http.post(Uri.parse("${ApiConfig.baseUrl}/groups"), headers: _headers(), body: jsonEncode(data));
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> joinGroup(String groupId, String userId) async {
    try {
      final response = await http.post(Uri.parse("${ApiConfig.baseUrl}/groups/$groupId/join"), headers: _headers(), body: jsonEncode({'userId': userId}));
      return _parse(response);
    } catch (e) { return _error(); }
  }

  // ─── SAFETY ───

  static Future<Map<String, dynamic>> startActiveTrip(Map<String, dynamic> data) async {
    try {
      final response = await http.post(Uri.parse("${ApiConfig.baseUrl}/safety/start"), headers: _headers(), body: jsonEncode(data));
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> completeActiveTrip(String tripId, String userId) async {
    try {
      final response = await http.post(Uri.parse("${ApiConfig.baseUrl}/safety/$tripId/complete"), headers: _headers(), body: jsonEncode({'userId': userId}));
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> triggerSOS(String tripId) async {
    try {
      final response = await http.post(Uri.parse("${ApiConfig.baseUrl}/safety/$tripId/sos"), headers: _headers(), body: jsonEncode({}));
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getEmergencyContacts(String userId) async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/safety/contacts?userId=$userId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> addEmergencyContact(Map<String, dynamic> data) async {
    try {
      final response = await http.post(Uri.parse("${ApiConfig.baseUrl}/safety/contacts"), headers: _headers(), body: jsonEncode(data));
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> deleteEmergencyContact(String contactId) async {
    try {
      final response = await http.delete(Uri.parse("${ApiConfig.baseUrl}/safety/contacts/$contactId"), headers: _headers());
      return _parse(response);
    } catch (e) { return _error(); }
  }


  // ─── MATCH SCORING ───

  /// Get real match score between current user and target user from matching engine
  static Future<Map<String, dynamic>> getMatchScore(String userId, String targetId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/matching/score?userId=$userId&targetId=$targetId"),
        headers: _headers(),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

  static Future<Map<String, dynamic>> getSmartMatches({
    required String tripId,
    required String userId,
    bool preferSameGender = false,
    int minScore = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/matching/$tripId?userId=$userId&preferSameGender=$preferSameGender&minScore=$minScore"),
        headers: _headers(),
      );
      return _parse(response);
    } catch (e) { return _error(); }
  }

}