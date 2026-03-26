import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});
  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _loadingContacts = true;
  String? _userId;

  @override
  void initState() { super.initState(); _loadContacts(); }

  Future<void> _loadContacts() async {
    final user = await AuthService.getSavedUser();
    _userId = user?['userId'];
    if (_userId == null) { setState(() => _loadingContacts = false); return; }
    final r = await ApiService.getEmergencyContacts(_userId!);
    if (mounted) setState(() {
      _loadingContacts = false;
      if (r['success'] == true) _contacts = List<Map<String, dynamic>>.from(r['data'] ?? []);
    });
  }

  void _callNumber(String number) async {
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _showAddContactDialog() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    String relation = 'Family';

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Add Emergency Contact', style: ZussGoTheme.displaySmall),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: ZussGoTheme.inputDecoration(hint: 'Name (e.g. Dad)'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary)),
        const SizedBox(height: 10),
        TextField(controller: phoneC, decoration: ZussGoTheme.inputDecoration(hint: '+91 98765 43210'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), keyboardType: TextInputType.phone),
        const SizedBox(height: 10),
        Row(children: ['Family', 'Friend', 'Other'].map((r) {
          final sel = relation == r;
          return Expanded(child: GestureDetector(
            onTap: () => setDialogState(() => relation = r),
            child: Container(margin: EdgeInsets.only(right: r != 'Other' ? 6 : 0), padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: sel ? ZussGoTheme.greenLight : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10),
                    border: sel ? Border.all(color: ZussGoTheme.green, width: 1.5) : null),
                alignment: Alignment.center, child: Text(r, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? ZussGoTheme.green : ZussGoTheme.textSecondary))),
          ));
        }).toList()),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: ZussGoTheme.textMuted))),
        TextButton(onPressed: () async {
          if (nameC.text.trim().isEmpty || phoneC.text.trim().isEmpty) return;
          Navigator.pop(ctx);
          await ApiService.addEmergencyContact({'userId': _userId, 'name': nameC.text.trim(), 'phone': phoneC.text.trim(), 'relation': relation});
          _loadContacts();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact added ✓'), backgroundColor: ZussGoTheme.green));
        }, child: Text('Add', style: TextStyle(color: ZussGoTheme.green, fontWeight: FontWeight.w600))),
      ],
    )));
  }

  void _showSOS() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: ZussGoTheme.rose.withValues(alpha: 0.08)),
            child: const Icon(Icons.warning_rounded, color: ZussGoTheme.rose, size: 22)),
        const SizedBox(width: 10), Text('Trigger SOS?', style: ZussGoTheme.displaySmall),
      ]),
      content: Text('This will dial emergency services (112) immediately.', style: ZussGoTheme.bodyMedium),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: ZussGoTheme.textMuted))),
        TextButton(onPressed: () { Navigator.pop(context); _callNumber('112'); }, child: Text('Call 112', style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w700))),
      ],
    ));
  }

  String _getRelationEmoji(String? relation) {
    switch (relation?.toLowerCase()) {
      case 'family': return '👨‍👩‍👦';
      case 'friend': return '👫';
      default: return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 18))),
        const SizedBox(height: 14),

        Text('Safety & Emergency', style: ZussGoTheme.displayMedium),
        const SizedBox(height: 4),
        Text('Manage contacts and access SOS', style: ZussGoTheme.bodySmall),
        const SizedBox(height: 20),

        // ── EMERGENCY CONTACTS ──
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Emergency Contacts', style: ZussGoTheme.displaySmall),
          GestureDetector(onTap: _showAddContactDialog, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, size: 14, color: ZussGoTheme.green),
                const SizedBox(width: 2),
                Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZussGoTheme.green)),
              ]))),
        ]),
        const SizedBox(height: 10),

        if (_loadingContacts)
          const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green))),

        if (!_loadingContacts && _contacts.isEmpty)
          Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: ZussGoTheme.cardDecoration,
              child: Column(children: [
                const Text('📞', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text('No emergency contacts', style: ZussGoTheme.labelBold),
                const SizedBox(height: 4),
                Text('Add contacts who should be notified in emergencies', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                GestureDetector(onTap: _showAddContactDialog, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(12)),
                    child: const Text('+ Add Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)))),
              ])),

        if (!_loadingContacts && _contacts.isNotEmpty)
          ...List.generate(_contacts.length, (i) {
            final c = _contacts[i];
            return Dismissible(
              key: Key(c['id'] ?? '$i'),
              direction: DismissDirection.endToStart,
              background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.delete_rounded, color: ZussGoTheme.rose)),
              onDismissed: (_) async {
                final id = c['id'];
                if (id != null) {
                  // Delete from backend
                  await ApiService.deleteEmergencyContact(id);
                }
                _loadContacts();
              },
              child: Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 8), decoration: ZussGoTheme.cardDecoration,
                  child: Row(children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: ZussGoTheme.green.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center, child: Text(_getRelationEmoji(c['relation']), style: const TextStyle(fontSize: 18))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c['name'] ?? 'Contact', style: ZussGoTheme.labelBold),
                      Text('${c['phone'] ?? ''} • ${c['relation'] ?? ''}', style: ZussGoTheme.bodySmall),
                    ])),
                    GestureDetector(onTap: () => _callNumber(c['phone'] ?? ''), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.call_rounded, size: 14, color: ZussGoTheme.green),
                          const SizedBox(width: 4),
                          Text('Call', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZussGoTheme.green)),
                        ]))),
                  ])),
            );
          }),

        const SizedBox(height: 8),
        Text('Swipe left to delete a contact', style: ZussGoTheme.bodySmall.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 24),

        // ── SOS SECTION ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ZussGoTheme.rose.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ZussGoTheme.rose.withValues(alpha: 0.08)),
          ),
          child: Column(children: [
            Text('Emergency SOS', style: ZussGoTheme.displaySmall.copyWith(color: ZussGoTheme.rose)),
            const SizedBox(height: 4),
            Text('Press and hold for emergencies', style: ZussGoTheme.bodySmall),
            const SizedBox(height: 16),

            GestureDetector(
              onLongPress: _showSOS,
              child: Container(width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEF4444)]),
                    boxShadow: [BoxShadow(color: ZussGoTheme.rose.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4)),
                      BoxShadow(color: ZussGoTheme.rose.withValues(alpha: 0.08), blurRadius: 40, spreadRadius: 8)]),
                child: const Center(child: Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Outfit'))),
              ),
            ),
            const SizedBox(height: 8),
            Text('Hold 3 seconds', style: TextStyle(fontSize: 11, color: ZussGoTheme.rose)),
            const SizedBox(height: 16),

            // Quick call buttons
            Row(children: [
              _QuickCall(icon: '🚔', label: 'Police', number: '100', onTap: () => _callNumber('100')),
              const SizedBox(width: 8),
              _QuickCall(icon: '🚑', label: 'Ambulance', number: '108', onTap: () => _callNumber('108')),
              const SizedBox(width: 8),
              _QuickCall(icon: '🆘', label: 'Emergency', number: '112', onTap: () => _callNumber('112')),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Info
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('What happens when you press SOS:', style: ZussGoTheme.labelBold.copyWith(fontSize: 12)),
              const SizedBox(height: 8),
              _InfoRow(icon: '📍', text: 'Your location is shared with emergency contacts'),
              _InfoRow(icon: '📞', text: 'Emergency services (112) are dialled'),
              _InfoRow(icon: '👥', text: 'Trip members are notified'),
              _InfoRow(icon: '🏥', text: 'Nearest hospital info shown'),
            ])),

        const SizedBox(height: 20),
      ]),
    )));
  }
}

class _QuickCall extends StatelessWidget {
  final String icon, label, number; final VoidCallback onTap;
  const _QuickCall({required this.icon, required this.label, required this.number, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ZussGoTheme.rose.withValues(alpha: 0.08))),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ZussGoTheme.rose)),
          Text(number, style: ZussGoTheme.bodySmall),
        ]))));
  }
}

class _InfoRow extends StatelessWidget {
  final String icon, text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 14)), const SizedBox(width: 8),
      Expanded(child: Text(text, style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textSecondary))),
    ]));
  }
}