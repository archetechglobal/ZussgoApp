import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Mock notifications matching V3 design
  final List<_NotifData> _today = [
    _NotifData('🤝', 'Arjun Sharma', ' sent you a companion request for ', 'Spiti Valley', '10 minutes ago', true, 'primary'),
    _NotifData('⭐', '', 'You earned ', '+100 TP', ' for completing the Rishikesh trip!', true, 'gold'),
  ];

  final List<_NotifData> _earlier = [
    _NotifData('💬', 'Priya Nair', ' sent you a message', '', 'Yesterday', false, 'lavender'),
    _NotifData('🗺️', '', 'New trip posted near your interests: ', 'Kasol–Kheerganga', 'Yesterday', false, 'sage'),
    _NotifData('🔥', 'Goa', ' is trending! 112 travelers are looking for companions', '', '2 days ago', false, 'rose'),
  ];

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
              Text('Notifications', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  for (var n in _today) n.unread = false;
                }),
                child: Text('Mark all read', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: c.primary)),
              ),
            ]),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                    child: Text('TODAY', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: c.muted, letterSpacing: 1)),
                  ),
                  ..._today.map((n) => _NotifItem(data: n)),

                  // Earlier
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text('EARLIER', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: c.muted, letterSpacing: 1)),
                  ),
                  ..._earlier.map((n) => _NotifItem(data: n)),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifData {
  final String emoji;
  final String bold1;
  final String text1;
  final String bold2;
  final String time;
  bool unread;
  final String colorType; // primary, gold, lavender, sage, rose

  _NotifData(this.emoji, this.bold1, this.text1, this.bold2, this.time, this.unread, this.colorType);
}

class _NotifItem extends StatelessWidget {
  final _NotifData data;
  const _NotifItem({required this.data});

  Color _bgColor(ZussGoColors c) {
    switch (data.colorType) {
      case 'primary': return c.primarySoft;
      case 'gold': return c.goldSoft;
      case 'lavender': return c.lavenderSoft;
      case 'sage': return c.sageSoft;
      case 'rose': return c.roseSoft;
      default: return c.primarySoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread indicator
          if (data.unread)
            Container(
              width: 3, height: 48,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(2)),
            ),

          // Icon
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: _bgColor(c), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(data.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.5),
                    children: [
                      if (data.bold1.isNotEmpty) TextSpan(text: data.bold1, style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
                      TextSpan(text: data.text1),
                      if (data.bold2.isNotEmpty) TextSpan(text: data.bold2, style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(data.time, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}