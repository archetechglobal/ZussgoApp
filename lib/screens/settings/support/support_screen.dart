import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _searchCtrl = TextEditingController();
  int?   _expandedFaq;
  String _searchQuery = '';

  final _faqs = [
    {'q': 'How does ZussGo matching work?',       'a': 'ZussGo uses AI to match you with compatible travel companions based on your travel style, interests, availability, and destination preferences. The more complete your profile, the better your matches will be.'},
    {'q': 'How do I edit my travel preferences?', 'a': 'Go to Settings → Edit Profile → scroll down to Travel Vibes. You can select tags that describe your travel style best.'},
    {'q': 'Can I travel with multiple companions?','a': 'Yes! ZussGo supports group travel. You can match with multiple people for the same trip and create group travel plans together.'},
    {'q': 'How do I report a suspicious user?',   'a': 'Go to Settings → Safety → Report User, or visit the user\'s profile and tap the three-dot menu → Report. We review all reports within 24 hours.'},
    {'q': 'What is ZussGo Pro?',                  'a': 'ZussGo Pro gives you unlimited matches, see who liked you, priority placement in search, advanced filters, a verified badge, and an ad-free experience.'},
    {'q': 'How do I delete my account?',          'a': 'Go to Settings → Support → Contact Us and select "Delete Account" as your topic. Our team will process your request within 7 business days.'},
    {'q': 'Is my data safe?',                     'a': 'Yes. We use industry-standard encryption for all data. We never sell your personal data. Read our full Privacy Policy in Settings → Legal.'},
  ];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Map<String, String>> get _filtered => _searchQuery.isEmpty
      ? List<Map<String, String>>.from(_faqs)
      : _faqs.where((f) =>
          f['q']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f['a']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList().cast<Map<String, String>>();

  void _showContactSheet() {
    final topics = ['General Inquiry', 'Account Issue', 'Report a Bug', 'Billing & Payment', 'Delete Account', 'Other'];
    String? selectedTopic;
    final msgCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: ZussGoTheme.bgSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contact Support', style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text('We usually respond within 24 hours', style: ZussGoTheme.bodySmall),
                const SizedBox(height: 20),
                Text('Topic', style: ZussGoTheme.bodySmall.copyWith(fontSize: 12, color: ZussGoTheme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: topics.map((t) => GestureDetector(
                  onTap: () => setSheet(() => selectedTopic = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedTopic == t ? ZussGoTheme.rose.withValues(alpha: 0.1) : ZussGoTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selectedTopic == t ? ZussGoTheme.rose.withValues(alpha: 0.5) : ZussGoTheme.borderDefault),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 13,
                      color: selectedTopic == t ? ZussGoTheme.rose : ZussGoTheme.textSecondary,
                      fontWeight: selectedTopic == t ? FontWeight.w600 : FontWeight.w400)),
                  ),
                )).toList()),
                const SizedBox(height: 16),
                Text('Message', style: ZussGoTheme.bodySmall.copyWith(fontSize: 12, color: ZussGoTheme.textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: msgCtrl, maxLines: 4,
                  style: ZussGoTheme.labelBold.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Describe your issue...',
                    hintStyle: TextStyle(color: ZussGoTheme.textMuted, fontSize: 14),
                    filled: true, fillColor: ZussGoTheme.bgSecondary,
                    contentPadding: const EdgeInsets.all(14),
                    border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ZussGoTheme.borderDefault)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ZussGoTheme.borderDefault)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ZussGoTheme.rose.withValues(alpha: 0.5))),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedTopic == null || msgCtrl.text.isEmpty ? null : () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Message sent! We will get back to you shortly.'),
                        backgroundColor: ZussGoTheme.rose, behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZussGoTheme.rose,
                      disabledBackgroundColor: ZussGoTheme.rose.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Send Message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(children: [
                GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary)),
                const SizedBox(width: 16),
                Text('Help Center', style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: ZussGoTheme.labelBold.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search for help...',
                        hintStyle: TextStyle(color: ZussGoTheme.textMuted),
                        prefixIcon: Icon(Icons.search_rounded, color: ZussGoTheme.textMuted, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                                child: Icon(Icons.close_rounded, color: ZussGoTheme.textMuted, size: 18))
                            : null,
                        filled: true, fillColor: ZussGoTheme.bgSecondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ZussGoTheme.borderDefault)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ZussGoTheme.borderDefault)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ZussGoTheme.rose.withValues(alpha: 0.5))),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Contact cards
                    Row(children: [
                      Expanded(child: _contactCard(icon: Icons.chat_bubble_rounded, label: 'Live Chat', sub: 'Chat with us', onTap: _showContactSheet)),
                      const SizedBox(width: 12),
                      Expanded(child: _contactCard(icon: Icons.email_rounded, label: 'Email Us', sub: 'support@zussgo.com', onTap: _showContactSheet)),
                    ]),
                    const SizedBox(height: 28),

                    Text('FREQUENTLY ASKED', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textMuted, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    if (filtered.isEmpty)
                      Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text('No results for "$_searchQuery"', style: ZussGoTheme.bodySmall)))
                    else
                      ...List.generate(filtered.length, (i) {
                        final faq    = filtered[i];
                        final isOpen = _expandedFaq == i;
                        return GestureDetector(
                          onTap: () => setState(() => _expandedFaq = isOpen ? null : i),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: ZussGoTheme.bgSecondary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isOpen ? ZussGoTheme.rose.withValues(alpha: 0.3) : ZussGoTheme.borderDefault),
                            ),
                            child: Column(children: [
                              Padding(padding: const EdgeInsets.all(14),
                                child: Row(children: [
                                  Expanded(child: Text(faq['q']!, style: ZussGoTheme.labelBold.copyWith(fontSize: 14))),
                                  Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: ZussGoTheme.textMuted, size: 20),
                                ])),
                              if (isOpen)
                                Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                  child: Text(faq['a']!, style: ZussGoTheme.bodySmall.copyWith(fontSize: 13, height: 1.6))),
                            ]),
                          ),
                        );
                      }),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showContactSheet,
                        icon: Icon(Icons.support_agent_rounded, color: ZussGoTheme.rose, size: 18),
                        label: Text('Contact Support', style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ZussGoTheme.rose.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
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

  Widget _contactCard({required IconData icon, required String label, required String sub, required VoidCallback onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(14), border: Border.all(color: ZussGoTheme.borderDefault)),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: ZussGoTheme.rose, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: ZussGoTheme.labelBold.copyWith(fontSize: 13)),
            Text(sub,   style: ZussGoTheme.bodySmall.copyWith(fontSize: 11)),
          ])),
        ]),
      ),
    );
}
