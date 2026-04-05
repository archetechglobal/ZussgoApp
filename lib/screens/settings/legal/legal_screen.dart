import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  int          _activeTab         = 0;
  Set<int>     _expandedSections  = {};

  final _terms = [
    {'title': '1. Acceptance of Terms',    'content': 'By accessing or using ZussGo, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service. ZussGo reserves the right to update these terms at any time.'},
    {'title': '2. Eligibility',            'content': 'You must be at least 18 years old to use ZussGo. By using our service, you represent and warrant that you meet this age requirement and that all registration information you submit is truthful and accurate.'},
    {'title': '3. User Conduct',           'content': 'You agree not to use ZussGo for any unlawful purpose. You must not harass, abuse, or harm other users. You may not impersonate others or provide false information. Any violation may result in immediate account termination.'},
    {'title': '4. Travel Safety',          'content': 'ZussGo facilitates connections between travellers but is not responsible for the actions of any user. You are solely responsible for your own safety and travel decisions. Always exercise caution when meeting travel companions in person.'},
    {'title': '5. Intellectual Property',  'content': 'All content, features, and functionality of ZussGo are the exclusive property of ZussGo Technologies Pvt. Ltd. and are protected by Indian and international copyright, trademark, and other intellectual property laws.'},
    {'title': '6. Termination',            'content': 'We reserve the right to suspend or terminate your account at any time for violations of these terms, fraudulent activity, or any behaviour we deem harmful to our community, at our sole discretion.'},
  ];

  final _privacy = [
    {'title': '1. Information We Collect', 'content': 'We collect information you provide when registering, including name, age, city, bio, and travel preferences. We also collect usage data, device information, and location data (with your permission) to improve our matching service.'},
    {'title': '2. How We Use Your Data',   'content': 'Your data is used to provide and improve ZussGo services, personalise your travel matching experience, send notifications (with your consent), and ensure the safety of our community. We never sell your personal data to third parties.'},
    {'title': '3. Data Sharing',           'content': 'Your profile information is visible to other ZussGo users as part of the matching feature. We may share anonymised, aggregated data for research purposes. We work with trusted service providers under strict confidentiality agreements.'},
    {'title': '4. Data Security',          'content': 'We use industry-standard SSL encryption and secure servers to protect your data. We regularly audit our systems for vulnerabilities. However, no method of transmission over the internet is 100% secure.'},
    {'title': '5. Your Rights',            'content': 'You have the right to access, correct, or delete your personal data at any time. You can export your data, withdraw consent, or request account deletion by contacting our support team.'},
    {'title': '6. Cookies',                'content': 'ZussGo uses cookies and similar tracking technologies to enhance your experience and analyse usage patterns. You can control cookie settings through your device settings.'},
    {'title': '7. Contact Us',             'content': 'For any privacy-related questions, contact our Data Protection Officer at privacy@zussgo.com or write to ZussGo Technologies Pvt. Ltd., Hyderabad, Telangana, India.'},
  ];

  @override
  Widget build(BuildContext context) {
    final sections = _activeTab == 0 ? _terms : _privacy;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(children: [
                GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary)),
                const SizedBox(width: 16),
                Text('Legal', style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
              ]),
            ),
            const SizedBox(height: 16),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZussGoTheme.borderDefault)),
                child: Row(children: [
                  _tab('Terms of Service', 0),
                  _tab('Privacy Policy',   1),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, size: 14, color: ZussGoTheme.textMuted),
                const SizedBox(width: 6),
                Text('Last updated: January 2025', style: ZussGoTheme.bodySmall.copyWith(fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            if (_expandedSections.length == sections.length) {
                              _expandedSections.clear();
                            } else {
                              _expandedSections = Set.from(List.generate(sections.length, (i) => i));
                            }
                          }),
                          child: Text(
                            _expandedSections.length == sections.length ? 'Collapse All' : 'Expand All',
                            style: TextStyle(color: ZussGoTheme.rose, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(sections.length, (i) {
                      final section = sections[i];
                      final isOpen  = _expandedSections.contains(i);
                      return GestureDetector(
                        onTap: () => setState(() => isOpen ? _expandedSections.remove(i) : _expandedSections.add(i)),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: ZussGoTheme.bgSecondary,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isOpen ? ZussGoTheme.rose.withValues(alpha: 0.3) : ZussGoTheme.borderDefault),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(padding: const EdgeInsets.all(14),
                              child: Row(children: [
                                Expanded(child: Text(section['title']!, style: ZussGoTheme.labelBold.copyWith(fontSize: 14))),
                                Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: ZussGoTheme.textMuted, size: 20),
                              ])),
                            if (isOpen)
                              Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                child: Text(section['content']!, style: ZussGoTheme.bodySmall.copyWith(fontSize: 13, height: 1.7))),
                          ]),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ZussGoTheme.rose.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ZussGoTheme.rose.withValues(alpha: 0.15)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Questions about our policies?', style: ZussGoTheme.labelBold.copyWith(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Contact us at legal@zussgo.com', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.rose, fontSize: 13)),
                      ]),
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

  Widget _tab(String label, int index) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _activeTab = index; _expandedSections.clear(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive ? ZussGoTheme.rose : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : ZussGoTheme.textSecondary)),
        ),
      ),
    );
  }
}
