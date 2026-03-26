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
  bool _sending = false, _sent = false;
  String? _tripId, _error;

  @override
  void didChangeDependencies() { super.didChangeDependencies(); final e = GoRouterState.of(context).extra; if (e is Map<String, dynamic> && e['tripId'] != null) _tripId = e['tripId']; }

  Future<void> _sendRequest() async {
    final u = await AuthService.getSavedUser(); final uid = u?['userId']; if (uid == null) return;
    setState(() { _sending = true; _error = null; });
    String? tid = _tripId;
    if (tid == null) {
      final tr = await ApiService.getMyTrips(uid);
      if (tr["success"] == true) { final up = List<Map<String, dynamic>>.from(tr["data"]?["upcoming"] ?? []); if (up.isNotEmpty) tid = up[0]['id']; }
    }
    if (tid == null) { setState(() { _sending = false; _error = 'Create a trip first'; }); return; }
    final r = await ApiService.sendMatchRequest(userId: uid, receiverId: widget.travelerId, tripId: tid, message: "Hey! Let's travel together 🌍");
    setState(() { _sending = false; });
    if (r["success"] == true && mounted) {
      setState(() => _sent = true);
      showDialog(context: context, barrierDismissible: false, builder: (_) => Dialog(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🌟', style: TextStyle(fontSize: 42)), const SizedBox(height: 10), Text('Request Sent!', style: ZussGoTheme.displaySmall), const SizedBox(height: 6),
            Text("They'll be notified soon!", style: ZussGoTheme.bodyMedium, textAlign: TextAlign.center), const SizedBox(height: 18),
            GradientButton(text: 'Done', onPressed: () { Navigator.pop(context); context.pop(); }),
          ]))));
    } else if (mounted) setState(() => _error = r["message"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Banner
      Container(height: 170, width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)])),
          child: Stack(children: [
            Positioned(top: 50, left: 16, child: GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18)))),
            Positioned(bottom: -28, left: 22, child: Container(width: 64, height: 64, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: ZussGoTheme.bgPrimary, width: 3), gradient: ZussGoTheme.gradientWarm, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)]),
                alignment: Alignment.center, child: const Icon(Icons.person_rounded, size: 28, color: Colors.white))),
          ])),

      Padding(padding: const EdgeInsets.fromLTRB(22, 36, 22, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Traveler', style: ZussGoTheme.displayMedium.copyWith(fontSize: 22)), Text('Explorer', style: ZussGoTheme.bodySmall)]),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(8)),
              child: Text('New User', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZussGoTheme.green))),
        ]),
        const SizedBox(height: 14),

        // Info card
        Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: ZussGoTheme.amber.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: ZussGoTheme.amber.withValues(alpha: 0.08))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('✦  Full profiles coming soon', style: TextStyle(color: ZussGoTheme.amber, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Detailed profiles with bio, ratings, mindset and trip history are being built.', style: ZussGoTheme.bodySmall),
            ])),

        if (_error != null) Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [Icon(Icons.info_outline_rounded, color: ZussGoTheme.rose, size: 16), const SizedBox(width: 6), Expanded(child: Text(_error!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 11)))])),

        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => context.pop(), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(border: Border.all(color: ZussGoTheme.borderDefault), borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center, child: Text('Pass', style: ZussGoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600))))),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: _sent
              ? Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_rounded, color: ZussGoTheme.green, size: 16), const SizedBox(width: 6), Text('Sent ✓', style: TextStyle(color: ZussGoTheme.green, fontWeight: FontWeight.w700))]))
              : GradientButton(text: "Let's Go Together 🤝", isLoading: _sending, onPressed: _sendRequest)),
        ]),
      ])),
    ])));
  }
}