import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final List<Map<String, String>> _blockedUsers = [
    {'initial': 'R', 'name': 'Ravi Kumar',   'reason': 'Blocked by you'},
    {'initial': 'A', 'name': 'Ankit Sharma', 'reason': 'Blocked by you'},
  ];

  void _showReportDialog() {
    final reasons = ['Fake profile', 'Inappropriate content', 'Harassment or bullying', 'Spam', 'Scam or fraud', 'Other'];
    String? selected;
    showModalBottomSheet(
      context: context,
      backgroundColor: ZussGoTheme.bgSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report a User', style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text('Select a reason for your report', style: ZussGoTheme.bodySmall),
              const SizedBox(height: 20),
              ...reasons.map((r) => GestureDetector(
                onTap: () => setSheet(() => selected = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected == r ? ZussGoTheme.rose.withValues(alpha: 0.1) : ZussGoTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected == r ? ZussGoTheme.rose.withValues(alpha: 0.4) : ZussGoTheme.borderDefault),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(r, style: ZussGoTheme.labelBold.copyWith(fontSize: 14))),
                    if (selected == r) Icon(Icons.check_circle_rounded, color: ZussGoTheme.rose, size: 18),
                  ]),
                ),
              )),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selected == null ? null : () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Report submitted. We will review it shortly.'),
                      backgroundColor: ZussGoTheme.rose,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZussGoTheme.rose,
                    disabledBackgroundColor: ZussGoTheme.rose.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _unblockUser(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ZussGoTheme.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Unblock User?', style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
        content: Text('Are you sure you want to unblock ${_blockedUsers[index]['name']}?', style: ZussGoTheme.bodySmall),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: ZussGoTheme.textSecondary))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _blockedUsers.removeAt(index));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('User unblocked.'),
                backgroundColor: ZussGoTheme.rose,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            },
            child: Text('Unblock', style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w600)),
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
                Text('Safety', style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: _actionCard(icon: Icons.block_rounded, label: 'Block User',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Go to a user profile to block them.'),
                          backgroundColor: ZussGoTheme.rose, behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))),
                      const SizedBox(width: 12),
                      Expanded(child: _actionCard(icon: Icons.flag_rounded, label: 'Report User', onTap: _showReportDialog)),
                    ]),
                    const SizedBox(height: 28),
                    Text('BLOCKED USERS', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textMuted, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    if (_blockedUsers.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(14), border: Border.all(color: ZussGoTheme.borderDefault)),
                        child: Column(children: [
                          Icon(Icons.check_circle_rounded, color: ZussGoTheme.textMuted, size: 32),
                          const SizedBox(height: 8),
                          Text('No blocked users', style: ZussGoTheme.bodySmall),
                        ]),
                      )
                    else
                      ...List.generate(_blockedUsers.length, (i) {
                        final u = _blockedUsers[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(14), border: Border.all(color: ZussGoTheme.borderDefault)),
                          child: Row(children: [
                            Container(width: 40, height: 40,
                              decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.1), shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(u['initial']!, style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w700, fontSize: 16))),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(u['name']!, style: ZussGoTheme.labelBold.copyWith(fontSize: 14)),
                              Text(u['reason']!, style: ZussGoTheme.bodySmall),
                            ])),
                            TextButton(onPressed: () => _unblockUser(i), child: Text('Unblock', style: TextStyle(color: ZussGoTheme.rose, fontSize: 13))),
                          ]),
                        );
                      }),
                    const SizedBox(height: 28),
                    Text('SAFETY TIPS', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textMuted, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _tip(Icons.person_search_rounded, 'Always verify your travel companion\'s profile before meeting in person.'),
                    _tip(Icons.location_on_rounded,   'Share your travel plans with a trusted friend or family member.'),
                    _tip(Icons.chat_rounded,           'Keep conversations on ZussGo until you feel comfortable.'),
                    _tip(Icons.report_problem_rounded, 'Report any suspicious behaviour immediately using the report button.'),
                    _tip(Icons.emergency_rounded,      'In an emergency, always contact local authorities first.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({required IconData icon, required String label, required VoidCallback onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZussGoTheme.borderDefault)),
        child: Column(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: ZussGoTheme.rose, size: 22)),
          const SizedBox(height: 10),
          Text(label, style: ZussGoTheme.labelBold.copyWith(fontSize: 13)),
        ]),
      ),
    );

  Widget _tip(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: ZussGoTheme.rose)),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: ZussGoTheme.bodySmall.copyWith(fontSize: 13, height: 1.5))),
    ]),
  );
}
