import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class ChatScreen extends StatelessWidget {
  final String matchId;
  const ChatScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final messages = [
      _Msg(me: false, text: "Hey! Saw you're heading to Manali too 🏔️", time: '10:32 AM'),
      _Msg(me: true, text: "Yess! Jan 5-10 right? What's your plan?", time: '10:33 AM'),
      _Msg(me: false, text: 'Solang Valley + Old Manali. Maybe Kasol too if we have time', time: '10:34 AM'),
      _Msg(me: true, text: "That's exactly my route! This is gonna be good 🔥", time: '10:35 AM'),
      _Msg(me: false, text: 'Should we split a hostel? Found one near Old Manali for ₹400/night', time: '10:36 AM'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ZussGoTheme.borderDefault))),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.15)),
                    ),
                    alignment: Alignment.center,
                    child: const Text('R', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8), fontFamily: 'Playfair Display')),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rohan', style: ZussGoTheme.labelBold),
                      Row(children: [
                        Container(width: 5, height: 5, decoration: const BoxDecoration(color: ZussGoTheme.mint, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('Online', style: TextStyle(fontSize: 11, color: ZussGoTheme.mint)),
                      ]),
                    ],
                  ),
                ],
              ),
            ),

            // Trip banner
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SHARED TRIP', style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, letterSpacing: 0.5)),
                      Text('🏔️ Manali · Jan 5-10', style: ZussGoTheme.labelBold.copyWith(fontSize: 13)),
                    ],
                  ),
                  Text('Details', style: TextStyle(fontSize: 12, color: ZussGoTheme.sky, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  return Align(
                    alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: m.me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                            decoration: BoxDecoration(
                              gradient: m.me ? ZussGoTheme.gradientPrimary : null,
                              color: m.me ? null : ZussGoTheme.bgSecondary,
                              border: m.me ? null : Border.all(color: ZussGoTheme.borderDefault),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(m.me ? 18 : 4),
                                bottomRight: Radius.circular(m.me ? 4 : 18),
                              ),
                            ),
                            child: Text(m.text, style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary, height: 1.5)),
                          ),
                          const SizedBox(height: 3),
                          Padding(
                            padding: EdgeInsets.only(left: m.me ? 0 : 4, right: m.me ? 4 : 0),
                            child: Text(m.time, style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: ZussGoTheme.borderDefault))),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(20), border: Border.all(color: ZussGoTheme.borderDefault)),
                      child: Text('Type a message...', style: TextStyle(fontSize: 14, color: ZussGoTheme.textMuted)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(gradient: ZussGoTheme.gradientPrimary, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
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

class _Msg {
  final bool me;
  final String text, time;
  _Msg({required this.me, required this.text, required this.time});
}
