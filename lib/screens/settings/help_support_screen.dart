import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Widget _faqItem(BuildContext context, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ZussGoTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? ZussGoTheme.border(context) : Colors.transparent),
        boxShadow: [if (Theme.of(context).brightness == Brightness.light) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: ZussGoTheme.lavender,
          collapsedIconColor: ZussGoTheme.mutedText(context),
          title: Text(title, style: context.textTheme.labelLarge!.copyWith(fontSize: 14, color: ZussGoTheme.primaryText(context))),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(description, style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.mutedText(context), height: 1.5)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZussGoTheme.scaffoldBg(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: ZussGoTheme.primaryText(context)),
          onPressed: () => context.pop(),
        ),
        title: Text('Help & Support', style: context.textTheme.displaySmall!.copyWith(color: ZussGoTheme.primaryText(context), fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [ZussGoTheme.lavender.withValues(alpha: 0.2), ZussGoTheme.lavender.withValues(alpha: 0.05)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ZussGoTheme.lavender.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 40, color: ZussGoTheme.lavender),
                  const SizedBox(height: 12),
                  Text('How can we help?', style: context.textTheme.displaySmall!.copyWith(color: ZussGoTheme.primaryText(context))),
                  const SizedBox(height: 6),
                  Text('Our support team is always ready to assist you.', style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.mutedText(context))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZussGoTheme.lavender,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Frequently Asked Questions', style: context.textTheme.displaySmall!.copyWith(color: ZussGoTheme.primaryText(context), fontSize: 16)),
            const SizedBox(height: 16),
            _faqItem(context, 'How do I find a travel buddy?', 'Search for your destination, browse travelers heading there at the same time, and send a match request. Once they accept, you can start chatting!'),
            _faqItem(context, 'Is there an SOS feature?', 'Yes. ZussGo provides an emergency active trip tracking feature. You can add emergency contacts and trigger an SOS directly from the app.'),
            _faqItem(context, 'How can I edit my profile?', 'Go to the Settings page and tap on Edit Profile. From there you can update your bio, travel style, interests, and more.'),
            _faqItem(context, 'Can I change my dates?', 'Right now you need to create a new trip with your updated dates. We will be adding date editing capabilities soon.'),
          ],
        ),
      ),
    );
  }
}
