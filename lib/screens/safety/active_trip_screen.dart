import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
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
      backgroundColor: ZussGoTheme.cardBg(context), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Add Emergency Contact', style: context.textTheme.displaySmall!.adaptive(context)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: ZussGoTheme.inputDecorationOf(context, hint: 'Name (e.g. Dad)'), style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context))),
        const SizedBox(height: 10),
        TextField(controller: phoneC, decoration: ZussGoTheme.inputDecorationOf(context, hint: '+91 98765 43210'), style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context)), keyboardType: TextInputType.phone),
        const SizedBox(height: 10),
        Row(children: ['Family', 'Friend', 'Other'].map((r) {
          final sel = relation == r;
          return Expanded(child: GestureDetector(
            onTap: () => setDialogState(() => relation = r),
            child: Container(margin: EdgeInsets.only(right: r != 'Other' ? 6 : 0), padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: sel ? context.colors.greenLight : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10),
                    border: sel ? Border.all(color: context.colors.green, width: 1.5) : null),
                alignment: Alignment.center, child: Text(r, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? context.colors.green : ZussGoTheme.textSecondary))),
          ));
        }).toList()),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: ZussGoTheme.mutedText(context)))),
        TextButton(onPressed: () async {
          if (nameC.text.trim().isEmpty || phoneC.text.trim().isEmpty) return;
          Navigator.pop(ctx);
          await ApiService.addEmergencyContact({'userId': _userId, 'name': nameC.text.trim(), 'phone': phoneC.text.trim(), 'relation': relation});
          _loadContacts();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contact added ✓'), backgroundColor: context.colors.green));
        }, child: Text('Add', style: TextStyle(color: context.colors.green, fontWeight: FontWeight.w600))),
      ],
    )));
  }

  bool _sendingSOS = false;
  int _countdown = 3;
  bool _sosTriggered = false;

  Future<void> _triggerInstantSOS() async {
    setState(() {
      _sendingSOS = true;
      _sosTriggered = false;
    });
    
    // ── COUNTDOWN OVERLAY ──
    _countdown = 3; 
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: const Color(0xFF991B1B), // Dark red
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text('EMERGENCY SOS', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  const Text('Triggering in...', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 20),
                  _SOSTimerWidget(
                    initialSeconds: _countdown,
                    onFinish: () {
                      if (Navigator.canPop(ctx)) Navigator.pop(ctx, true);
                    },
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx, false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white30)),
                      child: const Text('CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (result != true) {
      if (mounted) setState(() => _sendingSOS = false);
      return;
    }

    // Now proceed with actual SOS
    try {
      HapticFeedback.heavyImpact();
      
      // 1. Check Permissions Location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission locPerm = await Geolocator.checkPermission();
      if (locPerm == LocationPermission.denied) locPerm = await Geolocator.requestPermission();
      if (locPerm == LocationPermission.deniedForever) throw Exception('Location permissions are permanently denied');

      // 2. Get Location Payload
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String mapsLink = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      String message = 'EMERGENCY SOS: I need help! My current location is: $mapsLink';
      
      // 3. Android Auto-Send SMS logic
      if (Platform.isAndroid) {
        if (await Permission.sms.request().isGranted) {
          if (_contacts.isNotEmpty) {
            for (var contact in _contacts) {
              String phone = contact['phone'].toString().replaceAll(RegExp(r'[^\d+]'), '');
              try {
                await const MethodChannel('com.zussgo.zussgo/sms').invokeMethod('sendSms', {'phone': phone, 'message': message});
              } catch (_) {}
            }
          }
        } else {
          _fallbackSMSComposer(message);
        }
      } else {
        _fallbackSMSComposer(message);
      }

      // 4. Instant Call Logic
      if (Platform.isAndroid && await Permission.phone.request().isGranted) {
        await FlutterPhoneDirectCaller.callNumber('112');
      } else {
        await launchUrl(Uri.parse('tel:112'));
      }
      
      setState(() => _sosTriggered = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('SOS Activated! Alerts sent.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), backgroundColor: context.colors.rose));
      
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: context.colors.rose));
    } finally {
      if (mounted) setState(() => _sendingSOS = false);
    }
  }

  Future<void> _fallbackSMSComposer(String message) async {
    if (_contacts.isEmpty) return;
    String phones = _contacts.map((c) => c['phone'].toString().replaceAll(RegExp(r'[^\d+]'), '')).join(',');
    String uriString = 'sms:$phones${Platform.isIOS ? '&' : '?'}body=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(uriString);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _showSOS() async {
    int count = 3;
    setState(() => _countdown = count);

    // Initial haptic
    HapticFeedback.heavyImpact();

    _triggerInstantSOS();

    // The _triggerInstantSOS now handles the dialog and countdown for UX
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
    return Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context), body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.arrow_back_rounded, color: ZussGoTheme.secondaryText(context), size: 18))),
        const SizedBox(height: 14),

        Text('Safety & Emergency', style: context.textTheme.displayMedium!.adaptive(context)),
        const SizedBox(height: 4),
        Text('Manage contacts and access SOS', style: context.textTheme.bodySmall!.adaptive(context)),
        const SizedBox(height: 20),

        // ── EMERGENCY CONTACTS ──
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Emergency Contacts', style: context.textTheme.displaySmall!.adaptive(context)),
          GestureDetector(onTap: _showAddContactDialog, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: context.colors.greenLight, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, size: 14, color: context.colors.green),
                const SizedBox(width: 2),
                Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.green)),
              ]))),
        ]),
        const SizedBox(height: 10),

        if (_loadingContacts)
          SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green))),

        if (!_loadingContacts && _contacts.isEmpty)
          Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: ZussGoTheme.cardDecoration(context),
              child: Column(children: [
                Icon(Icons.phone_rounded, size: 32, color: context.colors.green),
                const SizedBox(height: 8),
                Text('No emergency contacts', style: context.textTheme.labelLarge!.adaptive(context)),
                const SizedBox(height: 4),
                Text('Add contacts who should be notified in emergencies', style: context.textTheme.bodySmall!.adaptive(context), textAlign: TextAlign.center),
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
                  decoration: BoxDecoration(color: context.colors.rose.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.delete_rounded, color: context.colors.rose)),
              onDismissed: (_) async {
                final id = c['id'];
                if (id != null) {
                  // Delete from backend
                  await ApiService.deleteEmergencyContact(id);
                }
                _loadContacts();
              },
              child: Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 8), decoration: ZussGoTheme.cardDecoration(context),
                  child: Row(children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: context.colors.green.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center, child: Text(_getRelationEmoji(c['relation']), style: const TextStyle(fontSize: 18))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c['name'] ?? 'Contact', style: context.textTheme.labelLarge!.adaptive(context)),
                      Text('${c['phone'] ?? ''} • ${c['relation'] ?? ''}', style: context.textTheme.bodySmall!.adaptive(context)),
                    ])),
                    GestureDetector(onTap: () => _callNumber(c['phone'] ?? ''), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: context.colors.greenLight, borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.call_rounded, size: 14, color: context.colors.green),
                          const SizedBox(width: 4),
                          Text('Call', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.green)),
                        ]))),
                  ])),
            );
          }),

        const SizedBox(height: 8),
        Text('Swipe left to delete a contact', style: context.textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 24),

        // ── SOS SECTION ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.rose.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.rose.withValues(alpha: 0.08)),
          ),
          child: Column(children: [
            Text('Emergency SOS', style: context.textTheme.displaySmall!.copyWith(color: context.colors.rose)),
            const SizedBox(height: 4),
            Text('Tap for emergencies', style: context.textTheme.bodySmall!.adaptive(context)),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _sendingSOS ? null : _showSOS,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 85, height: 85,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: LinearGradient(colors: _sosTriggered ? [context.colors.rose, const Color(0xFF991B1B)] : [const Color(0xFFDC2626), const Color(0xFFEF4444)]),
                    boxShadow: [BoxShadow(color: context.colors.rose.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4)),
                      BoxShadow(color: _sosTriggered ? context.colors.rose.withValues(alpha: 0.2) : context.colors.rose.withValues(alpha: 0.08), blurRadius: _sosTriggered ? 50 : 40, spreadRadius: _sosTriggered ? 12 : 8)]),
                child: Center(child: Text(_sosTriggered ? 'ACTIVE' : 'SOS', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Outfit'))),
              ),
            ),
            const SizedBox(height: 8),
            Text(_sosTriggered ? 'SOS ALERT ACTIVE' : 'Tap to trigger', style: TextStyle(fontSize: 11, fontWeight: _sosTriggered ? FontWeight.w700 : FontWeight.w400, color: context.colors.rose)),
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
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('What happens when you press SOS:', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
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
        decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), borderRadius: BorderRadius.circular(14),
            border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: ZussGoTheme.border(context)) : null,
            boxShadow: [if (Theme.of(context).brightness == Brightness.light) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.colors.rose)),
          Text(number, style: context.textTheme.bodySmall!.adaptive(context)),
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
      Expanded(child: Text(text, style: context.textTheme.bodySmall!.copyWith(color: ZussGoTheme.secondaryText(context)))),
    ]));
  }
}

class _SOSTimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onFinish;
  const _SOSTimerWidget({required this.initialSeconds, required this.onFinish});
  @override
  State<_SOSTimerWidget> createState() => _SOSTimerWidgetState();
}

class _SOSTimerWidgetState extends State<_SOSTimerWidget> {
  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) setState(() => _timeLeft--);
        HapticFeedback.lightImpact();
      } else {
        timer.cancel();
        widget.onFinish();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CountdownCircle(seconds: _timeLeft);
  }
}

class _CountdownCircle extends StatelessWidget {
  final int seconds;
  const _CountdownCircle({required this.seconds});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 20)],
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
        child: Text('$seconds', key: ValueKey(seconds), style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, fontFamily: 'Outfit')),
      ),
    );
  }
}