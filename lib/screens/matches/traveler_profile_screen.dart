import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class TravelerProfileScreen extends StatefulWidget {
  final String travelerId;
  const TravelerProfileScreen({super.key, required this.travelerId});

  @override
  State<TravelerProfileScreen> createState() => _TravelerProfileScreenState();
}

class _TravelerProfileScreenState extends State<TravelerProfileScreen> {
  bool _isSending = false;
  bool _requestSent = false;
  String? _errorMessage;
  String? _tripId; // received from previous screen or fetched

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to get tripId from navigation extra
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> && extra['tripId'] != null) {
      _tripId = extra['tripId'];
    }
  }

  Future<void> _sendMatchRequest() async {
    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId == null) return;

    setState(() { _isSending = true; _errorMessage = null; });

    // If we don't have a tripId from navigation, find user's first trip
    String? tripId = _tripId;
    if (tripId == null) {
      final tripsResult = await ApiService.getMyTrips(userId);
      if (tripsResult["success"] == true && tripsResult["data"] != null) {
        final upcoming = List<Map<String, dynamic>>.from(tripsResult["data"]["upcoming"] ?? []);
        if (upcoming.isNotEmpty) {
          tripId = upcoming[0]['id'];
        }
      }
    }

    if (tripId == null) {
      setState(() {
        _isSending = false;
        _errorMessage = 'Create a trip first before sending match requests. Go to Explore → pick a destination → select dates.';
      });
      return;
    }

    final result = await ApiService.sendMatchRequest(
      userId: userId,
      receiverId: widget.travelerId,
      tripId: tripId,
      message: "Hey! Let's travel together 🌍",
    );

    setState(() { _isSending = false; });

    if (result["success"] == true && mounted) {
      setState(() => _requestSent = true);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: ZussGoTheme.bgSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🌟', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Request Sent!', style: ZussGoTheme.displaySmall),
              const SizedBox(height: 8),
              Text("They'll be notified and you'll hear back soon!", style: ZussGoTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('Check the Matches tab for updates ✨', style: ZussGoTheme.bodySmall),
              const SizedBox(height: 24),
              GradientButton(text: 'Done', onPressed: () { Navigator.pop(context); context.pop(); }),
            ]),
          ),
        ),
      );
    } else if (mounted) {
      setState(() => _errorMessage = result["message"] ?? "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              // Avatar
              Center(
                child: Column(children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZussGoTheme.rose.withValues(alpha: 0.06),
                      border: Border.all(color: ZussGoTheme.rose.withValues(alpha: 0.2), width: 2.5),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.person_rounded, size: 40, color: ZussGoTheme.rose.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 12),
                  Text('Traveler Profile', style: ZussGoTheme.displayMedium),
                  const SizedBox(height: 4),
                  Text('Explorer', style: ZussGoTheme.bodySmall),
                ]),
              ),
              const SizedBox(height: 32),

              // Info notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ZussGoTheme.amber.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ZussGoTheme.amber.withValues(alpha: 0.1)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('✦  Full profiles coming soon', style: TextStyle(color: ZussGoTheme.amber, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Detailed traveler profiles with bio, interests, ratings, and photos are being built. For now, send a match request to connect!', style: ZussGoTheme.bodySmall),
                ]),
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ZussGoTheme.rose.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ZussGoTheme.rose.withValues(alpha: 0.15)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline_rounded, color: ZussGoTheme.rose, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 12, fontWeight: FontWeight.w500))),
                  ]),
                ),

              // Action buttons
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ZussGoTheme.borderDefault),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Pass', style: ZussGoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _requestSent
                      ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: ZussGoTheme.mint.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ZussGoTheme.mint.withValues(alpha: 0.2)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.check_circle_rounded, color: ZussGoTheme.mint, size: 18),
                      const SizedBox(width: 8),
                      Text('Request Sent ✓', style: TextStyle(color: ZussGoTheme.mint, fontWeight: FontWeight.w700)),
                    ]),
                  )
                      : GradientButton(
                    text: "Let's Go Together 🤝",
                    isLoading: _isSending,
                    onPressed: _sendMatchRequest,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}