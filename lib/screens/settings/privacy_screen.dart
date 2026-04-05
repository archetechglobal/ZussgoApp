import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class PrivacySafetyScreen extends StatelessWidget {
  const PrivacySafetyScreen({super.key});

  Widget _policySection(BuildContext context, IconData icon, String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: context.colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: context.colors.amber, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.labelLarge!.copyWith(fontSize: 15, color: ZussGoTheme.primaryText(context))),
                const SizedBox(height: 6),
                Text(text, style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.mutedText(context), height: 1.5)),
              ],
            ),
          )
        ],
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
        title: Text('Privacy & Safety', style: context.textTheme.displaySmall!.copyWith(color: ZussGoTheme.primaryText(context), fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Safety is our Priority', style: context.textTheme.displayMedium!.copyWith(color: ZussGoTheme.primaryText(context))),
            const SizedBox(height: 10),
            Text('Learn about how we protect your data and provide a secure environment for all travelers.', style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.mutedText(context))),
            const SizedBox(height: 32),
            _policySection(context, Icons.lock_rounded, 'Data Encryption', 'All your chats and personal details are securely encrypted. We never share your data with third party brokers without your explicit consent.'),
            _policySection(context, Icons.verified_user_rounded, 'Verified Profiles', 'We encourage all users to verify their profiles via email to ensure authenticity. Look for the trusted traveler score.'),
            _policySection(context, Icons.block_rounded, 'Block & Report', 'If you ever feel uncomfortable, you can instantly block or report another user. Our team investigates every report thoroughly within 24 hours.'),
            _policySection(context, Icons.location_off_rounded, 'Location Privacy', 'Your exact live location is never shared with anyone unless you explicitly trigger an SOS broadcast to your predefined emergency contacts.'),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('Read our full Privacy Policy', style: TextStyle(color: context.colors.amber, decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
