import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/share_trip_card.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/destination_images.dart';

class PostStatusSheet extends StatefulWidget {
  const PostStatusSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PostStatusSheet(),
    );
  }

  @override
  State<PostStatusSheet> createState() => _PostStatusSheetState();
}

class _PostStatusSheetState extends State<PostStatusSheet> {
  List<Map<String, dynamic>> _destinations = [];
  Map<String, dynamic>? _selectedDest;
  DateTime? _startDate, _endDate;
  String? _budget;
  bool _loading = true, _creating = false;
  bool _showSuccess = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  Map<String, dynamic>? _userData;

  @override
  void initState() { super.initState(); _loadDestinations(); }

  Future<void> _loadDestinations() async {
    final r = await ApiService.getDestinations();
    if (mounted) setState(() {
      _loading = false;
      if (r["success"] == true) _destinations = List<Map<String, dynamic>>.from(r["data"] ?? []);
    });
  }

  Future<void> _pickDates() async {
    final range = await showDateRangePicker(
      context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (c, child) => Theme(data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: context.colors.green)), child: child!),
    );
    if (range != null) setState(() { _startDate = range.start; _endDate = range.end; });
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}';
  }

  Future<void> _post() async {
    if (_selectedDest == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a destination'))); return; }
    if (_startDate == null || _endDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your travel dates'))); return; }

    final user = await AuthService.getSavedUser();
    if (user?['userId'] == null) return;

    setState(() => _creating = true);
    final r = await ApiService.createTrip(
      userId: user!['userId'],
      destinationId: _selectedDest!['id'],
      startDate: _startDate!.toUtc().toIso8601String(),
      endDate: _endDate!.toUtc().toIso8601String(),
      budget: _budget,
    );
    setState(() => _creating = false);

    if (r["success"] == true && mounted) {
      setState(() {
        _showSuccess = true;
        _userData = user;
      });
      // Optionally still show the snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Posted! You\'re heading to ${_selectedDest!['name']}.'),
        backgroundColor: context.colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccessView(context);

    final colors = ZussGoTheme.colors(context);
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: ZussGoTheme.scaffoldBg(context),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ZussGoTheme.border(context), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          Text("I'm Going To...", style: context.textTheme.displayMedium!.adaptive(context)),
          const SizedBox(height: 4),
          Text('Let other travelers find and connect with you', style: context.textTheme.bodySmall!.adaptive(context)),
          const SizedBox(height: 20),

          // ── SELECT DESTINATION ──
          Text('Where are you going?', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
          const SizedBox(height: 8),

          if (_loading)
            SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green))),

          if (!_loading)
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _destinations.length,
                itemBuilder: (_, i) {
                  final d = _destinations[i];
                  final sel = _selectedDest?['id'] == d['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDest = d),
                    child: Container(
                      width: 85, margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: ZussGoTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: sel ? context.colors.green : ZussGoTheme.border(context), width: sel ? 2 : 1),
                        boxShadow: sel ? [BoxShadow(color: context.colors.green.withValues(alpha: 0.3), blurRadius: 6)] : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(sel ? 14 : 15),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (DestinationImages.getImageFromData(d) != null) ...[
                              Image.network(DestinationImages.getImageFromData(d)!, fit: BoxFit.cover),
                              Container(color: Colors.black.withValues(alpha: sel ? 0.3 : 0.5)),
                            ] else
                              Container(color: colors.bgMuted),
                            
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (DestinationImages.getImageFromData(d) == null)
                                  Icon(Icons.public_rounded, size: 24, color: ZussGoTheme.mutedText(context)),
                                if (sel && DestinationImages.getImageFromData(d) != null)
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    d['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                      color: DestinationImages.getImageFromData(d) != null 
                                          ? Colors.white 
                                          : colors.textPrimary
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (_selectedDest != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                if (DestinationImages.getImageFromData(_selectedDest!) != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        DestinationImages.getImageFromData(_selectedDest!)!,
                        width: 36, height: 36, fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.check_circle_rounded, color: context.colors.green, size: 16),
                  ),
                Expanded(child: Text('${_selectedDest!['name']}', style: TextStyle(fontSize: 13, color: context.colors.green, fontWeight: FontWeight.w600))),
              ]),
            ),

          const SizedBox(height: 20),

          // ── SELECT DATES ──
          Text('When?', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDates,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Icon(Icons.calendar_month_rounded, color: context.colors.green, size: 20),
                const SizedBox(width: 10),
                Text(
                  _startDate != null ? '${_fmtDate(_startDate!)} — ${_fmtDate(_endDate!)} (${_endDate!.difference(_startDate!).inDays} days)' : 'Tap to select dates',
                  style: context.textTheme.bodyMedium!.copyWith(color: _startDate != null ? ZussGoTheme.textPrimary : context.colors.textMuted),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // ── BUDGET ──
          Text('Budget', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: ['Budget', 'Mid-range', 'Luxury'].map((b) {
            final sel = _budget == b;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _budget = b),
              child: Container(
                margin: EdgeInsets.only(right: b != 'Luxury' ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? colors.green.withValues(alpha: 0.2) : colors.bgMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: sel ? Border.all(color: context.colors.green, width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(b, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? context.colors.green : ZussGoTheme.secondaryText(context))),
              ),
            ));
          }).toList()),

          const SizedBox(height: 28),
          GradientButton(text: "Post Status", isLoading: _creating, onPressed: _post),
          const SizedBox(height: 8),
          Center(child: Text('Others will see you on the destination page', style: context.textTheme.bodySmall!.adaptive(context))),
        ]),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: ZussGoTheme.scaffoldBg(context),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ZussGoTheme.border(context), borderRadius: BorderRadius.circular(2)))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  Text("Trip Posted!", style: context.textTheme.displayMedium!.adaptive(context)),
                  const SizedBox(height: 8),
                  Text("Your trip is live. Share it with your friends!", style: context.textTheme.bodyMedium!.adaptive(context), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  
                  // Shareable Card
                  Screenshot(
                    controller: _screenshotController,
                    child: ShareTripCard(
                      destinationName: _selectedDest?['name'] ?? 'Destination',
                      dates: _startDate != null ? '${_fmtDate(_startDate!)} - ${_fmtDate(_endDate!)}' : '',
                      budget: _budget,
                      userName: _userData?['fullName'] ?? 'Traveler',
                      destinationData: _selectedDest,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _ShareButton(
                          icon: Icons.camera_alt_rounded,
                          label: "Instagram Story",
                          color: const Color(0xFFE1306C),
                          onPressed: () => _share(social: 'instagram'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShareButton(
                          icon: Icons.chat_bubble_rounded,
                          label: "WhatsApp",
                          color: const Color(0xFF25D366),
                          onPressed: () => _share(social: 'whatsapp'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Done", style: TextStyle(color: context.colors.textMuted, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share({required String social}) async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/trip_share.png').create();
      await imagePath.writeAsBytes(image);

      final result = await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: "I'm heading to ${_selectedDest?['name']}! Find me on ZussGo. #ZussGo #Travel",
      );

      if (result.status == ShareResultStatus.success) {
        // Success
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sharing: $e")));
    }
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}