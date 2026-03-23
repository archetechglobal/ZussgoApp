import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  int  _selectedPlan = 1;
  bool _isLoading    = false;

  final _plans = [
    {'label': 'Monthly',  'price': '₹299',   'period': '/month',   'saving': null},
    {'label': 'Yearly',   'price': '₹1,999', 'period': '/year',    'saving': 'Save 44%'},
    {'label': 'Lifetime', 'price': '₹4,999', 'period': 'one time', 'saving': 'Best Value'},
  ];

  final _features = [
    {'icon': Icons.favorite_rounded,       'label': 'Unlimited Matches',         'free': false},
    {'icon': Icons.visibility_rounded,     'label': 'See Who Liked You',          'free': false},
    {'icon': Icons.flash_on_rounded,       'label': 'Priority in Search Results', 'free': false},
    {'icon': Icons.chat_bubble_rounded,    'label': 'Unlimited Messaging',        'free': false},
    {'icon': Icons.travel_explore_rounded, 'label': 'Advanced Trip Filters',      'free': false},
    {'icon': Icons.verified_rounded,       'label': 'Verified Pro Badge',         'free': false},
    {'icon': Icons.block_rounded,          'label': 'Ad-Free Experience',         'free': false},
    {'icon': Icons.star_rounded,           'label': 'Basic Matching',             'free': true},
    {'icon': Icons.search_rounded,         'label': 'Explore Travellers',         'free': true},
  ];

  Future<void> _subscribe() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Welcome to ZussGo Pro! 🎉'),
        backgroundColor: ZussGoTheme.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      context.pop();
    }
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
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Column(
                  children: [
                    Container(width: 72, height: 72,
                      decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, shape: BoxShape.circle),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32)),
                    const SizedBox(height: 16),
                    Text('ZussGo Pro', style: ZussGoTheme.displaySmall.copyWith(fontSize: 26)),
                    const SizedBox(height: 6),
                    Text('Travel smarter. Match better. Connect deeper.',
                      style: ZussGoTheme.bodySmall.copyWith(fontSize: 14), textAlign: TextAlign.center),
                    const SizedBox(height: 28),

                    // Plan selector
                    Row(
                      children: List.generate(_plans.length, (i) {
                        final plan       = _plans[i];
                        final isSelected = _selectedPlan == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlan = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? ZussGoTheme.rose.withValues(alpha: 0.1) : ZussGoTheme.bgSecondary,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? ZussGoTheme.rose.withValues(alpha: 0.6) : ZussGoTheme.borderDefault,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(children: [
                                if (plan['saving'] != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: ZussGoTheme.rose, borderRadius: BorderRadius.circular(6)),
                                    child: Text(plan['saving']!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                                  )
                                else const SizedBox(height: 18),
                                Text(plan['price']!, style: ZussGoTheme.labelBold.copyWith(fontSize: 16, color: isSelected ? ZussGoTheme.rose : null)),
                                Text(plan['period']!, style: ZussGoTheme.bodySmall.copyWith(fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(plan['label']!, style: ZussGoTheme.bodySmall.copyWith(fontSize: 12)),
                              ]),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Feature table
                    Container(
                      decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZussGoTheme.borderDefault)),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [
                            const Expanded(child: SizedBox()),
                            SizedBox(width: 60, child: Text('Free', style: ZussGoTheme.bodySmall.copyWith(fontSize: 12), textAlign: TextAlign.center)),
                            SizedBox(width: 60, child: Text('Pro', style: ZussGoTheme.labelBold.copyWith(fontSize: 12, color: ZussGoTheme.rose), textAlign: TextAlign.center)),
                          ]),
                        ),
                        const Divider(height: 1),
                        ..._features.map((f) => Column(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(children: [
                              Icon(f['icon'] as IconData, size: 18, color: ZussGoTheme.textSecondary),
                              const SizedBox(width: 10),
                              Expanded(child: Text(f['label'] as String, style: ZussGoTheme.labelBold.copyWith(fontSize: 13))),
                              SizedBox(width: 60, child: Icon((f['free'] as bool) ? Icons.check_rounded : Icons.close_rounded, size: 18, color: (f['free'] as bool) ? Colors.green : ZussGoTheme.textMuted)),
                              SizedBox(width: 60, child: Icon(Icons.check_rounded, size: 18, color: ZussGoTheme.rose)),
                            ]),
                          ),
                          Divider(height: 1, color: ZussGoTheme.borderDefault),
                        ])),
                      ]),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _subscribe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ZussGoTheme.rose,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Get ${_plans[_selectedPlan]['label']} Pro — ${_plans[_selectedPlan]['price']}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Cancel anytime · Secure payment · No hidden fees',
                      style: ZussGoTheme.bodySmall.copyWith(fontSize: 12), textAlign: TextAlign.center),
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
