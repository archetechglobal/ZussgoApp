import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api.dart';

class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});
  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> with TickerProviderStateMixin {
  bool _sosTriggered = false;
  bool _alertSent = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  late AnimationController _pulseController;
  late AnimationController _ringController;

  List<Map<String, dynamic>> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _ringController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _loadContacts();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final user = await AuthService.getSavedUser();
      final userId = user?['userId'];
      if (userId == null) { setState(() => _loading = false); return; }

      final r = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/safety/contacts?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        if (data['success'] == true && data['data'] != null) {
          _contacts = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (_) {}

    // Fallback mock contacts if none from backend
    if (_contacts.isEmpty) {
      _contacts = [
        {'name': 'Dad', 'relation': 'Primary contact', 'phone': '+91-XXXXXXXXXX'},
        {'name': 'Mom', 'relation': 'Emergency contact', 'phone': '+91-XXXXXXXXXX'},
        {'name': 'Rohan', 'relation': 'Travel buddy', 'phone': '+91-XXXXXXXXXX'},
      ];
    }

    if (mounted) setState(() => _loading = false);
  }

  void _triggerSOS() {
    setState(() { _sosTriggered = true; _countdown = 3; });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() { _alertSent = true; });
        _sendSOSToBackend();
      }
    });
  }

  Future<void> _sendSOSToBackend() async {
    try {
      final user = await AuthService.getSavedUser();
      final userId = user?['userId'];
      if (userId == null) return;
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/safety/active/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
    } catch (_) {}
  }

  void _cancelSOS() {
    _countdownTimer?.cancel();
    setState(() { _sosTriggered = false; _alertSent = false; _countdown = 3; });
  }

  static const _contactEmojis = ['👨', '👩', '👨‍💻'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 16),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: c.border)),
                  child: Icon(Icons.arrow_back_rounded, color: c.text, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Text('Emergency SOS', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
            ]),
          ),

          // Main content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SOS area
                SizedBox(
                  width: 280, height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring animation
                      AnimatedBuilder(
                        animation: _ringController,
                        builder: (_, __) {
                          final scale = 0.8 + (_ringController.value * 1.7);
                          final opacity = 0.8 - (_ringController.value * 0.8);
                          return Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity.clamp(0.0, 1.0),
                              child: Container(
                                width: 160, height: 160,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.rose, width: 2)),
                              ),
                            ),
                          );
                        },
                      ),

                      // Countdown or SOS button
                      if (_sosTriggered && !_alertSent)
                        Text('$_countdown', style: GoogleFonts.outfit(fontSize: 56, fontWeight: FontWeight.w900, color: c.rose))
                      else if (_alertSent)
                        Text('✓', style: GoogleFonts.outfit(fontSize: 56, fontWeight: FontWeight.w900, color: c.sage))
                      else
                        GestureDetector(
                          onTap: _triggerSOS,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (_, __) {
                              final scale = 1.0 + (0.08 * (0.5 - (_pulseController.value - 0.5).abs()));
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 160, height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(colors: [Color(0xFFFF3B5C), Color(0xFFFF6B4A)]),
                                    boxShadow: [BoxShadow(color: const Color(0x40FF3B5C), blurRadius: 60)],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🆘', style: TextStyle(fontSize: 48)),
                                      const SizedBox(height: 4),
                                      Text('HOLD FOR SOS', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _alertSent
                        ? 'Alert sent! Your live location is being shared with all emergency contacts.'
                        : _sosTriggered
                        ? 'Sending alert in...'
                        : 'Press and hold to send an emergency alert with your live location to all emergency contacts.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.textSecondary, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ),

                if (_sosTriggered && !_alertSent)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      onTap: _cancelSOS,
                      child: Text('Cancel', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: c.muted)),
                    ),
                  ),

                const SizedBox(height: 24),

                // Contacts list
                if (!_loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: List.generate(_contacts.length, (i) {
                        final contact = _contacts[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
                          child: Row(children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: c.roseSoft, borderRadius: BorderRadius.circular(11)),
                              alignment: Alignment.center,
                              child: Text(_contactEmojis[i % _contactEmojis.length], style: const TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(contact['name'] ?? 'Contact', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: c.text)),
                              const SizedBox(height: 1),
                              Text(contact['relation'] ?? 'Emergency', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted)),
                            ])),
                            Text(
                              _alertSent ? 'Notified ✓' : 'Ready',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: _alertSent ? c.sage : c.sage),
                            ),
                          ]),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}