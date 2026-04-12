import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _newMatches    = true;
  bool _messages      = true;
  bool _tripUpdates   = true;
  bool _travelAlerts  = false;
  bool _promoOffers   = false;
  bool _weeklySummary = true;
  bool _pushEnabled   = true;
  bool _emailEnabled  = false;

  Widget _sectionLabel(String title) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 10),
    child: Text(title.toUpperCase(), style: ZussGoTheme.bodySmall.copyWith(
      color: ZussGoTheme.textMuted, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
  );

  Widget _toggle({required IconData icon, required String label, required String sub,
    required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ZussGoTheme.borderDefault))),
      child: Row(
        children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: ZussGoTheme.textSecondary)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: ZussGoTheme.labelBold.copyWith(fontSize: 14)),
            Text(sub, style: ZussGoTheme.bodySmall),
          ])),
          Switch.adaptive(
            value: value, onChanged: onChanged,
            activeColor: ZussGoTheme.rose,
            activeTrackColor: ZussGoTheme.rose.withValues(alpha: 0.25),
            inactiveThumbColor: ZussGoTheme.textMuted,
            inactiveTrackColor: ZussGoTheme.bgSecondary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(children: [
                GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary)),
                const SizedBox(width: 16),
                Text('Notifications', style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Delivery'),
                    _toggle(icon: Icons.notifications_active_rounded, label: 'Push Notifications', sub: 'Alerts on your device', value: _pushEnabled, onChanged: (v) => setState(() => _pushEnabled = v)),
                    _toggle(icon: Icons.email_rounded, label: 'Email Notifications', sub: 'Updates to your inbox', value: _emailEnabled, onChanged: (v) => setState(() => _emailEnabled = v)),

                    _sectionLabel('Matching'),
                    _toggle(icon: Icons.favorite_rounded, label: 'New Matches', sub: 'When someone matches with you', value: _newMatches, onChanged: (v) => setState(() => _newMatches = v)),
                    _toggle(icon: Icons.chat_bubble_rounded, label: 'Messages', sub: 'New messages from matches', value: _messages, onChanged: (v) => setState(() => _messages = v)),

                    _sectionLabel('Trips'),
                    _toggle(icon: Icons.flight_takeoff_rounded, label: 'Trip Updates', sub: 'Changes to your trips', value: _tripUpdates, onChanged: (v) => setState(() => _tripUpdates = v)),
                    _toggle(icon: Icons.travel_explore_rounded, label: 'Travel Alerts', sub: 'Deals and destination tips', value: _travelAlerts, onChanged: (v) => setState(() => _travelAlerts = v)),

                    _sectionLabel('General'),
                    _toggle(icon: Icons.summarize_rounded, label: 'Weekly Summary', sub: 'Your week in ZussGo', value: _weeklySummary, onChanged: (v) => setState(() => _weeklySummary = v)),
                    _toggle(icon: Icons.local_offer_rounded, label: 'Promotions & Offers', sub: 'Deals and special offers', value: _promoOffers, onChanged: (v) => setState(() => _promoOffers = v)),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Notification preferences saved!'),
                            backgroundColor: ZussGoTheme.rose,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ));
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ZussGoTheme.rose,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Save Preferences', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
