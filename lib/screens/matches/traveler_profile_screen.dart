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
  bool _sending = false, _sent = false, _loading = true;
  String? _tripId, _error;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  double? _score;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final e = GoRouterState.of(context).extra;
    if (e is Map<String, dynamic>) {
      if (e['tripId'] != null) _tripId = e['tripId'];
      if (e['score'] != null) _score = (e['score'] as num).toDouble();
    }
  }

  Future<void> _loadProfile() async {
    final user = await AuthService.getSavedUser();
    final uid = user?['userId'];
    final r = await ApiService.getUserProfile(widget.travelerId, currentUserId: uid);
    if (mounted) {
      if (r["success"] == true) {
        setState(() {
          _profile = r["data"];
          _loading = false;
        });
      } else {
        setState(() {
          _error = r["message"] ?? "Could not load profile";
          _loading = false;
        });
      }
    }
  }

  Future<void> _sendRequest() async {
    final u = await AuthService.getSavedUser();
    final uid = u?['userId'];
    if (uid == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    String? tid = _tripId;
    if (tid == null) {
      final tr = await ApiService.getMyTrips(uid);
      if (tr["success"] == true) {
        final up = List<Map<String, dynamic>>.from(tr["data"]?["upcoming"] ?? []);
        if (up.isNotEmpty) tid = up[0]['id'];
      }
    }
    if (tid == null) {
      setState(() {
        _sending = false;
        _error = 'Create a trip first to send a request';
      });
      return;
    }
    final r = await ApiService.sendMatchRequest(userId: uid, receiverId: widget.travelerId, tripId: tid, message: "I'd love to connect for an upcoming trip");
    setState(() {
      _sending = false;
    });
    if (r["success"] == true && mounted) {
      setState(() => _sent = true);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
              backgroundColor: ZussGoTheme.cardBg(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle_rounded, size: 44, color: context.colors.green),
                    const SizedBox(height: 10),
                    Text('Request Sent!', style: context.textTheme.displaySmall!.adaptive(context)),
                    const SizedBox(height: 6),
                    Text("They'll be notified soon!", style: context.textTheme.bodyMedium!, textAlign: TextAlign.center),
                    const SizedBox(height: 18),
                    GradientButton(
                        text: 'Done',
                        onPressed: () {
                          Navigator.pop(context);
                          context.pop();
                        }),
                  ]))));
    } else if (mounted) setState(() => _error = r["message"]);
  }

  Widget _chip(String label, {IconData? icon, String? emoji, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color ?? context.colors.green, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[Text(emoji, style: const TextStyle(fontSize: 14)), const SizedBox(width: 4)],
          if (icon != null) ...[Icon(icon, size: 14, color: Colors.white), const SizedBox(width: 4)],
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Outfit')),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, double width) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ZussGoTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZussGoTheme.border(context)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
          Text(label, style: TextStyle(fontSize: 10, color: ZussGoTheme.mutedText(context))),
        ],
      ),
    );
  }

  Widget _vibeChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Outfit')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context), body: Center(child: CircularProgressIndicator(color: context.colors.green)));
    }

    if (_profile == null) {
      return Scaffold(
          backgroundColor: ZussGoTheme.scaffoldBg(context),
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: BackButton(color: ZussGoTheme.primaryText(context))),
          body: Center(child: Text('Profile not found', style: context.textTheme.displaySmall!.adaptive(context))));
    }

    final p = _profile!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = ((p['fullName'] ?? 'U') as String).substring(0, 1).toUpperCase();
    final matchScore = _score != null ? "${_score!.round()}%" : "85%";

    return Scaffold(
      backgroundColor: ZussGoTheme.scaffoldBg(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner & Top Section exactly like Image 3
            SizedBox(
              height: 380,
              child: Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEAB308), Color(0xFFF59E0B)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Center(
                        child: Text(
                          'Full Profile',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 220,
                    left: 24,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: ZussGoTheme.scaffoldBg(context),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFF59E0B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(initials, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Playfair Display')),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 330,
                    left: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['fullName'] ?? 'Traveler', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 26, fontWeight: FontWeight.bold, color: ZussGoTheme.primaryText(context))),
                            Text('${p['age'] ?? 'Age'} • ${p['gender'] ?? 'Gender'} • ${p['city'] ?? 'Location'}', style: TextStyle(fontSize: 14, color: ZussGoTheme.mutedText(context), fontFamily: 'Outfit')),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${p['rating'] ?? '4.8'}', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w800, color: context.colors.amber)),
                            Row(
                              children: [
                                Icon(Icons.star_rounded, color: context.colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text('Rating', style: TextStyle(fontSize: 11, color: context.colors.amber)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio Quote
                  if (p['bio'] != null && p['bio'].toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: ZussGoTheme.mutedBg(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ZussGoTheme.border(context), width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '"${p['bio']}"',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: ZussGoTheme.primaryText(context),
                            fontSize: 14,
                            fontFamily: 'Outfit',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Stats Row
                  LayoutBuilder(builder: (context, constraints) {
                    final itemW = (constraints.maxWidth - 16) / 3;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statCard('Trips', '${p['tripsCount'] ?? 0}', context.colors.green, itemW),
                        _statCard('Friends', '${p['friendsCount'] ?? 0}', context.colors.sky, itemW),
                        _statCard('Match', matchScore, context.colors.rose, itemW),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),

                  // Style & Mindset
                  Text('Style & Mindset', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.bold, color: ZussGoTheme.primaryText(context))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      if (p['travelStyle'] != null) _chip(p['travelStyle']),
                      if (p['schedule'] != null) _chip(p['schedule']),
                      if (p['socialEnergy'] != null) _chip(p['socialEnergy']),
                      if (p['planningStyle'] != null) _chip(p['planningStyle']),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Interests
                  if (p['interests'] != null && (p['interests'] as List).isNotEmpty) ...[
                    Text('Interests', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.bold, color: ZussGoTheme.primaryText(context))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (p['interests'] as List).map((i) => _vibeChip(i.toString(), Icons.local_activity_rounded, context.colors.sky)).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Values
                  if (p['values'] != null && (p['values'] as List).isNotEmpty) ...[
                    Text('Values', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.bold, color: ZussGoTheme.primaryText(context))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (p['values'] as List).map((v) => _vibeChip(v.toString(), Icons.favorite_rounded, context.colors.rose)).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Energy Level
                  if (p['energyLevel'] != null) ...[
                    Text('Energy Level', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.bold, color: ZussGoTheme.primaryText(context))),
                    const SizedBox(height: 12),
                    _vibeChip(p['energyLevel'], Icons.bolt_rounded, context.colors.amber),
                  ],

                  if (_error != null)
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(color: context.colors.rose.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [Icon(Icons.info_outline_rounded, color: context.colors.rose, size: 16), SizedBox(width: 6), Expanded(child: Text(_error!, style: TextStyle(color: context.colors.rose, fontSize: 13)))])),

                  const SizedBox(height: 24),

                  // Action Buttons matching Mockup 3
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: ZussGoTheme.cardBg(context),
                              border: Border.all(color: ZussGoTheme.border(context), width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 6)],
                            ),
                            alignment: Alignment.center,
                            child: Text('Pass', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: ZussGoTheme.primaryText(context), fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _sent
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(color: context.colors.greenLight, borderRadius: BorderRadius.circular(16)),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_rounded, color: context.colors.green, size: 20), SizedBox(width: 8), Text('Sent ✓', style: TextStyle(color: context.colors.green, fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 16))]))
                            : GestureDetector(
                                onTap: _sendRequest,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  decoration: BoxDecoration(color: const Color(0xFF2D9F6F), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF2D9F6F).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_sending) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) else ...[
                                        const Text("Send Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Outfit')),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/trip-complete', extra: {'trip': {'id': _tripId}, 'ratee': _profile, 'isGroup': false}),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: context.colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded, color: context.colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text('Rate Traveler', style: TextStyle(color: context.colors.amber, fontWeight: FontWeight.w700, fontFamily: 'Outfit', fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}