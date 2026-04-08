import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends ChangeNotifier {
  int _unreadMessageCount = 0;
  int _pendingRequestCount = 0;
  bool _showHighlight = false;
  Timer? _timer;

  int get unreadMessageCount => _unreadMessageCount;
  int get pendingRequestCount => _pendingRequestCount;
  int get totalUnread => _unreadMessageCount + _pendingRequestCount;
  bool get hasUnseenNotifications => _showHighlight && totalUnread > 0;

  NotificationService() {
    _loadLastSeen();
    _startPolling();
  }

  Future<void> _loadLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    _showHighlight = prefs.getBool('notifications_show_highlight') ?? false;
    notifyListeners();
  }

  void _startPolling() {
    fetch();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => fetch());
  }

  Future<void> fetch() async {
    final user = await AuthService.getSavedUser();
    final uid = user?['userId'];
    if (uid == null) return;

    try {
      // 1. Fetch unread messages
      final unreadRes = await ApiService.getUnreadCount(uid);
      int newUnread = _unreadMessageCount;
      int newPending = _pendingRequestCount;

      if (unreadRes['success'] == true && unreadRes['data'] != null) {
        newUnread = (unreadRes['data']['count'] as num?)?.toInt() ?? 0;
      }

      // 2. Fetch pending match requests
      final reqRes = await ApiService.getPendingRequests(uid);
      if (reqRes['success'] == true && reqRes['data'] != null) {
        newPending = (reqRes['data'] as List).length;
      }

      // Logic: If the total unread count increased, show the highlight
      if (newUnread + newPending > _unreadMessageCount + _pendingRequestCount) {
        _showHighlight = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notifications_show_highlight', true);
      }
      
      _unreadMessageCount = newUnread;
      _pendingRequestCount = newPending;

      notifyListeners();
    } catch (e) {
      // Silently fail rather than interrupting the user interface
    }
  }

  /// Manually force a refresh and immediately notify listeners
  void refresh() {
    fetch();
  }

  Future<void> markAsSeen() async {
    if (!_showHighlight) return;
    _showHighlight = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_show_highlight', false);
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
