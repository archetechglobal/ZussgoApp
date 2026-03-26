import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});
  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> _pending = [], _sent = [], _matches = [];
  bool _loading = true;
  String? _userId;

  @override
  void initState() { super.initState(); _loadAll(); }

  Future<void> _loadAll() async {
    final u = await AuthService.getSavedUser();
    _userId = u?['userId'];
    if (_userId == null) { setState(() => _loading = false); return; }
    final r = await Future.wait([ApiService.getPendingRequests(_userId!), ApiService.getSentRequests(_userId!), ApiService.getMatches(_userId!)]);
    if (mounted) setState(() {
      _loading = false;
      if (r[0]["success"] == true) _pending = List<Map<String, dynamic>>.from(r[0]["data"] ?? []);
      if (r[1]["success"] == true) _sent = List<Map<String, dynamic>>.from(r[1]["data"] ?? []);
      if (r[2]["success"] == true) _matches = List<Map<String, dynamic>>.from(r[2]["data"] ?? []);
    });
  }

  Future<void> _accept(String id) async {
    final r = await ApiService.acceptMatchRequest(id, _userId!);
    if (r["success"] == true && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Matched! 🎉'), backgroundColor: ZussGoTheme.green));
    _loadAll();
  }

  Future<void> _reject(String id) async { await ApiService.rejectMatchRequest(id, _userId!); _loadAll(); }

  Color _c(int i) { const cs = [ZussGoTheme.green, ZussGoTheme.sky, ZussGoTheme.amber, ZussGoTheme.rose, ZussGoTheme.lavender]; return cs[i % cs.length]; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: Stack(children: [
      SafeArea(bottom: false, child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 8, 22, 90), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Connections', style: ZussGoTheme.displayLarge.copyWith(fontSize: 26)),
          GestureDetector(onTap: () => context.push('/chats'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(12)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 14), SizedBox(width: 5), Text('Chats', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))]))),
        ]),
        const SizedBox(height: 16),

        if (_loading) Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green))),

        if (!_loading && _pending.isEmpty && _sent.isEmpty && _matches.isEmpty)
          Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: ZussGoTheme.cardDecoration,
              child: Column(children: [const Text('🤝', style: TextStyle(fontSize: 36)), const SizedBox(height: 10), Text('No connections yet', style: ZussGoTheme.displaySmall), const SizedBox(height: 6), Text('Plan a trip and find companions!', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center)])),

        if (!_loading && _pending.isNotEmpty) ...[
          Text('REQUESTS FOR YOU', style: TextStyle(fontSize: 10, color: ZussGoTheme.amber, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...List.generate(_pending.length, (i) {
            final req = _pending[i]; final s = req['sender'] ?? {}; final d = req['trip']?['destination'] ?? {};
            return Container(padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 8), decoration: ZussGoTheme.cardDecoration,
                child: Column(children: [
                  Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: _c(i).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)), alignment: Alignment.center,
                        child: Text((s['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _c(i), fontFamily: 'Playfair Display'))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s['fullName'] ?? '', style: ZussGoTheme.labelBold), Text('${d['emoji'] ?? ''} ${d['name'] ?? ''} • ${s['travelStyle'] ?? ''}', style: ZussGoTheme.bodySmall)])),
                  ]),
                  if (req['message'] != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text('"${req['message']}"', style: ZussGoTheme.bodySmall.copyWith(fontStyle: FontStyle.italic, color: ZussGoTheme.textSecondary))),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: GestureDetector(onTap: () => _reject(req['id']), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(border: Border.all(color: ZussGoTheme.borderDefault), borderRadius: BorderRadius.circular(12)), alignment: Alignment.center,
                        child: Text('Pass', style: ZussGoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600))))),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: GestureDetector(onTap: () => _accept(req['id']), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center,
                        child: const Text("Let's Go! 🤝", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))))),
                  ]),
                ]));
          }),
          const SizedBox(height: 14),
        ],

        if (!_loading && _sent.isNotEmpty) ...[
          Text('SENT', style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...List.generate(_sent.length, (i) {
            final req = _sent[i]; final r = req['receiver'] ?? {}; final d = req['trip']?['destination'] ?? {}; final st = req['status'] ?? 'PENDING';
            final sc = st == 'ACCEPTED' ? ZussGoTheme.green : st == 'REJECTED' ? ZussGoTheme.rose : ZussGoTheme.amber;
            return Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 6), decoration: ZussGoTheme.glassCard,
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center,
                      child: Text((r['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ZussGoTheme.textSecondary))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r['fullName'] ?? '', style: ZussGoTheme.labelBold.copyWith(fontSize: 13)), Text('${d['emoji'] ?? ''} ${d['name'] ?? ''}', style: ZussGoTheme.bodySmall)])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: sc.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                      child: Text(st, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: sc))),
                ]));
          }),
          const SizedBox(height: 14),
        ],

        if (!_loading && _matches.isNotEmpty) ...[
          Text('MATCHED', style: TextStyle(fontSize: 10, color: ZussGoTheme.green, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...List.generate(_matches.length, (i) {
            final m = _matches[i]; final o = m['otherUser'] ?? {}; final d = m['trip']?['destination'] ?? {}; final cv = m['conversation'];
            return GestureDetector(onTap: () { if (cv?['id'] != null) context.push('/chat/${cv['id']}'); },
                child: Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 6), decoration: ZussGoTheme.glassCard,
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: _c(i).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)), alignment: Alignment.center,
                          child: Text((o['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _c(i), fontFamily: 'Playfair Display'))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o['fullName'] ?? '', style: ZussGoTheme.labelBold), Text('${d['emoji'] ?? ''} ${d['name'] ?? ''}', style: ZussGoTheme.bodySmall),
                        if (cv?['lastMessage'] != null) Text(cv['lastMessage'], style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(8)),
                          child: Text('Chat →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ZussGoTheme.green))),
                    ])));
          }),
        ],
      ]))),
      const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 2)),
    ]));
  }
}