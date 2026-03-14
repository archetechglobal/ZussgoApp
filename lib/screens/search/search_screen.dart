import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedFilter = 0;
  final _filters = ['All', 'Explorer', 'Wanderer', 'Luxe', 'Solo Female', 'Budget'];

  final _destinations = [
    {'name': 'Goa', 'emoji': '🏖️', 'count': 47},
    {'name': 'Manali', 'emoji': '🏔️', 'count': 31},
    {'name': 'Rishikesh', 'emoji': '🧘', 'count': 22},
    {'name': 'Jaipur', 'emoji': '🏰', 'count': 18},
    {'name': 'Ladakh', 'emoji': '🏍️', 'count': 29},
    {'name': 'Varanasi', 'emoji': '🪔', 'count': 14},
    {'name': 'Hampi', 'emoji': '🛕', 'count': 11},
    {'name': 'Meghalaya', 'emoji': '🌊', 'count': 9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + search
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search destinations...',
                              prefixIcon: Icon(Icons.search, color: ZussGoTheme.textMuted.withValues(alpha: 0.5), size: 20),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: ZussGoTheme.amber.withValues(alpha: 0.3)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Date picker
                    Row(
                      children: [
                        Expanded(child: _DateBox(label: 'DEPART', value: 'Dec 20')),
                        const SizedBox(width: 10),
                        Expanded(child: _DateBox(label: 'RETURN', value: 'Dec 25')),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filters
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (context, i) {
                          final isSelected = i == _selectedFilter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFilter = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  gradient: isSelected ? ZussGoTheme.gradientPrimary : null,
                                  color: isSelected ? null : ZussGoTheme.bgCard,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isSelected ? Colors.transparent : ZussGoTheme.borderDefault),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _filters[i],
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : ZussGoTheme.textMuted),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('All Destinations', style: ZussGoTheme.displaySmall),
                    const SizedBox(height: 14),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.15,
                      ),
                      itemCount: _destinations.length,
                      itemBuilder: (context, i) {
                        final d = _destinations[i];
                        return GestureDetector(
                          onTap: () => context.push('/destination/${(d['name'] as String).toLowerCase()}'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ZussGoTheme.bgCard,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: ZussGoTheme.borderDefault),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(d['emoji'] as String, style: const TextStyle(fontSize: 30)),
                                const SizedBox(height: 8),
                                Text(d['name'] as String, style: ZussGoTheme.labelBold),
                                const SizedBox(height: 2),
                                Text('${d['count']} travelers', style: TextStyle(fontSize: 11, color: ZussGoTheme.mint)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 1)),
          ],
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  const _DateBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: ZussGoTheme.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZussGoTheme.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value, style: ZussGoTheme.labelBold.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
