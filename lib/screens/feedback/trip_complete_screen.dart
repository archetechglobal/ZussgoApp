import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class TripCompleteScreen extends StatefulWidget {
  final Map<String, dynamic>? trip;
  final Map<String, dynamic>? ratee;
  final bool isGroup;

  const TripCompleteScreen({super.key, this.trip, this.ratee, this.isGroup = false});

  @override
  State<TripCompleteScreen> createState() => _TripCompleteScreenState();
}

class _TripCompleteScreenState extends State<TripCompleteScreen> with SingleTickerProviderStateMixin {
  int _score = 0;
  final Set<String> _selectedChips = {};
  final TextEditingController _reviewCtrl = TextEditingController();
  bool _isLoading = false;

  final List<String> _individualChips = ['Friendly', 'Fun', 'Reliable', 'Over-planner', 'Late', 'Boring'];
  final List<String> _groupChips = ['Great Energy', 'Organized', 'Chaotic', 'Fun', 'Reliable'];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default to a 2-tab layout just so we can demonstrate both Mockups 4 and 5 in the same screen easily
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.isGroup ? 1 : 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(String raterId, String rateeId, String type) async {
    if (_score == 0) return;
    setState(() => _isLoading = true);
    final response = await ApiService.createRating(
      userId: raterId,
      ratedId: rateeId,
      tripId: widget.trip?['id'] ?? '00000000-0000-0000-0000-000000000000',
      score: _score,
      review: _reviewCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    if (response['success'] == true) {
      context.pop(); // Go back home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to submit rating'), backgroundColor: context.colors.rose),
      );
    }
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _score = index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < _score ? Icons.star_rounded : Icons.star_border_rounded,
              color: index < _score ? context.colors.amber : Colors.grey.withValues(alpha: 0.3),
              size: 50,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = _selectedChips.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedChips.remove(label);
          } else {
            _selectedChips.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.green.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? context.colors.green : ZussGoTheme.border(context)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? context.colors.green : ZussGoTheme.mutedText(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontFamily: 'Outfit',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildIndividualRate() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rate ${widget.ratee?['fullName'] ?? 'Traveler'}', style: context.textTheme.displaySmall!.adaptive(context).copyWith(fontSize: 28)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(20)),
                child: Text('Reviewing', style: TextStyle(fontSize: 12, color: ZussGoTheme.mutedText(context), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.rose.withValues(alpha: 0.1),
              ),
              child: Center(child: Text(((widget.ratee?['fullName'] ?? 'U') as String).substring(0,1).toUpperCase(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.rose))),
            ),
          ),
          const SizedBox(height: 24),
          _buildStars(),
          const SizedBox(height: 30),
          Text('How was ${widget.ratee?['fullName'] ?? 'Traveler'}?', style: context.textTheme.titleMedium!.adaptive(context)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _individualChips.map((c) => _buildChip(c)).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _reviewCtrl,
            maxLines: 4,
            style: context.textTheme.bodyMedium!.adaptive(context),
            decoration: InputDecoration(
              hintText: 'Write a public review...',
              hintStyle: TextStyle(color: ZussGoTheme.mutedText(context).withValues(alpha: 0.5)),
              filled: true,
              fillColor: ZussGoTheme.mutedBg(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), border: Border.all(color: ZussGoTheme.border(context), width: 1.5), borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.center,
                    child: Text('Skip', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: ZussGoTheme.primaryText(context), fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    if (_score == 0) return;
                    final u = await AuthService.getSavedUser();
                    _submit(u?['userId'] ?? 'user', widget.ratee?['id'] ?? 'dummy', 'individual');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(color: _score > 0 ? context.colors.green : ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(16), boxShadow: [_score > 0 ? BoxShadow(color: context.colors.green.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)) : const BoxShadow(color: Colors.transparent)]),
                    alignment: Alignment.center,
                    child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Submit Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Outfit')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupRate() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rate Group', style: context.textTheme.displaySmall!.adaptive(context).copyWith(fontSize: 28)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(20)),
                child: Text('Completed', style: TextStyle(fontSize: 12, color: ZussGoTheme.mutedText(context), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: 120,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(left: 0, child: CircleAvatar(radius: 26, backgroundColor: Colors.pink.withValues(alpha: 0.2), child: const Text('P', style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 20)))),
                  Positioned(left: 30, child: CircleAvatar(radius: 26, backgroundColor: Colors.blue.withValues(alpha: 0.2), child: const Text('R', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)))),
                  Positioned(left: 60, child: CircleAvatar(radius: 26, backgroundColor: Colors.orange.withValues(alpha: 0.2), child: const Text('A', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20)))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('Group Expedition', style: context.textTheme.titleLarge!.adaptive(context))),
          const SizedBox(height: 24),
          _buildStars(),
          const SizedBox(height: 30),
          Text('Group Vibe', style: context.textTheme.titleMedium!.adaptive(context)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _groupChips.map((c) => _buildChip(c)).toList(),
          ),
          const SizedBox(height: 30),
          Text('Quick Rate Each', style: context.textTheme.titleMedium!.adaptive(context)),
          const SizedBox(height: 16),
          _userQuickRate('Rahul', context.colors.sky, 5),
          _userQuickRate('Amit', context.colors.amber, 4),
          _userQuickRate('Sneha', context.colors.rose, 5),

          const SizedBox(height: 40),
          Row(
            children: [
               Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), border: Border.all(color: ZussGoTheme.border(context), width: 1.5), borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.center,
                    child: Text('Skip', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: ZussGoTheme.primaryText(context), fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    if (_score == 0) return;
                    final u = await AuthService.getSavedUser();
                    // In a real app, logic would loop members. For now we submit for the group entity.
                    _submit(u?['userId'] ?? 'user', widget.trip?['id'] ?? 'group_id', 'group');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(color: _score > 0 ? context.colors.green : ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(16), boxShadow: [_score > 0 ? BoxShadow(color: context.colors.green.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)) : const BoxShadow(color: Colors.transparent)]),
                    alignment: Alignment.center,
                    child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Submit Group Rating", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Outfit')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userQuickRate(String name, Color c, int stars) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: c.withValues(alpha: 0.1), child: Text(name[0], style: TextStyle(color: c, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Text(name, style: context.textTheme.bodyLarge!.adaptive(context)),
          const Spacer(),
          Row(
            children: List.generate(5, (index) => Icon(index < stars ? Icons.star_rounded : Icons.star_border_rounded, color: index < stars ? context.colors.amber : Colors.grey.withValues(alpha: 0.3), size: 18)),
          ),
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
        leading: BackButton(color: ZussGoTheme.primaryText(context)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: context.colors.green,
          tabs: const [
            Tab(text: "Individual Rate"),
            Tab(text: "Group Rate"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildIndividualRate(), // Matches Mockup 4
            _buildGroupRate(),      // Matches Mockup 5
          ],
        ),
      ),
    );
  }
}