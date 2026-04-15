import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    } else {
      return "http://localhost:8000";
    }
    //"http://3.108.184.61:8000";
  }

  // Auth
  static String get signup => "$baseUrl/auth/signup";
  static String get login => "$baseUrl/auth/login";
  static String get verifyOtp => "$baseUrl/auth/verify-otp";
  static String get forgotPassword => "$baseUrl/auth/forgot-password";
  static String get resetPassword => "$baseUrl/auth/reset-password";
  static String get resendOtp => "$baseUrl/auth/resend-otp";
  static String get profileSetup => "$baseUrl/auth/profile-setup";
  static String get users => "$baseUrl/auth/users";

  // Destinations
  static String get destinations => "$baseUrl/destinations";
  static String get destinationSearch => "$baseUrl/destinations/search";
  static String destinationBySlug(String slug) => "$baseUrl/destinations/$slug";

  // Trips
  static String get trips => "$baseUrl/trips";
  static String tripById(String id) => "$baseUrl/trips/$id";
  static String tripTravelers(String id) => "$baseUrl/trips/$id/travelers";

  // Match Requests
  static String get matchRequests => "$baseUrl/match-requests";
  static String get matchRequestsPending => "$baseUrl/match-requests/pending";
  static String get matchRequestsSent => "$baseUrl/match-requests/sent";
  static String matchRequestAccept(String id) => "$baseUrl/match-requests/$id/accept";
  static String matchRequestReject(String id) => "$baseUrl/match-requests/$id/reject";

  // Matches
  static String get matches => "$baseUrl/matches";
  static String matchById(String id) => "$baseUrl/matches/$id";
  static String matchUnmatch(String id) => "$baseUrl/matches/$id/unmatch";

  // Conversations
  static String get conversations => "$baseUrl/conversations";

  // Messages
  static String get messages => "$baseUrl/messages";
  static String get messagesUnread => "$baseUrl/messages/unread";
  static String messagesByConversation(String id) => "$baseUrl/messages/$id";

  // Ratings
  static String get ratings => "$baseUrl/ratings";
  static String ratingsByUser(String id) => "$baseUrl/ratings/$id";

  // Blocks
  static String get blocks => "$baseUrl/blocks";

  // Reports
  static String get reports => "$baseUrl/reports";

  // Safety & SOS
  static String get safetyContacts => "$baseUrl/safety/contacts";
  static String safetyDeleteContact(String id) => "$baseUrl/safety/contacts/$id";
  static String get safetyStartTrip => "$baseUrl/safety/start";
  static String get safetyActiveTrip => "$baseUrl/safety/active";
  static String safetyCompleteTrip(String id) => "$baseUrl/safety/$id/complete";
  static String safetySOS(String id) => "$baseUrl/safety/$id/sos";
  static String safetyUpdateLocation(String id) => "$baseUrl/safety/$id/location";

  // Rewards / Trek Points
  static String get rewards => "$baseUrl/rewards";
  static String get rewardsBalance => "$baseUrl/rewards/balance";
  static String get rewardsHistory => "$baseUrl/rewards/history";
  static String get rewardsEarn => "$baseUrl/rewards/earn";
  static String get rewardsEarnAction => "$baseUrl/rewards/earn-action";
  static String get rewardsRedeem => "$baseUrl/rewards/redeem";
  static String get rewardsInitialize => "$baseUrl/rewards/initialize";
}