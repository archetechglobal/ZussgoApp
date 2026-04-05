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
    final r = await Future.wait([
      ApiService.getPendingRequests(_userId!),
      ApiService.getSentRequests(_userId!),
      ApiService.getMatches(_userId!),
    ]);
    if (mounted) setState(() {
      _loading = false;
      if (r[0]["success"] == true) _pending = List<Map<String, dynamic>>.from(r[0]["data"] ?? []);
      if (r[1]["success"] == true) _sent    = List<Map<String, dynamic>>.from(r[1]["data"] ?? []);
      if (r[2]["success"] == true) _matches = List<Map<String, dynamic>>.from(r[2]["data"] ?? []);
    });
  }

  Future<void> _accept(String id) async {
    final r = await ApiService.acceptMatchRequest(id, _userId!);
    if (r["success"] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connection request accepted.'), backgroundColor: context.colors.green));
    }
    _loadAll();
  }

  Future<void> _reject(String id) async { await ApiService.rejectMatchRequest(id, _userId!); _loadAll(); }

  Color _c(int i) {
    final cs = [context.colors.green, context.colors.sky, context.colors.amber, context.colors.rose, ZussGoTheme.lavender];
    return cs[i % cs.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgPage    = ZussGoTheme.scaffoldBg(context);
    final bgCard    = ZussGoTheme.cardBg(context);
    final bgMuted   = ZussGoTheme.mutedBg(context);
    final borderCol = ZussGoTheme.border(context);
    final textPri   = ZussGoTheme.primaryText(context);
    final textMut   = ZussGoTheme.mutedText(context);
    final textSec   = ZussGoTheme.secondaryText(context);

    return Scaffold(
      backgroundColor: bgPage,
      body: Stack(fit: StackFit.expand, children: [

        SafeArea(bottom: false, child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 90),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── HEADER ──
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Connections', style: context.textTheme.displayLarge!.copyWith(fontSize: 28, color: textPri, fontWeight: FontWeight.w800)),
              GestureDetector(
                onTap: () => context.push('/chats'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgMuted,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.chat_bubble_outline_rounded, color: textPri, size: 16),
                    const SizedBox(width: 6),
                    Text('Chats', style: TextStyle(color: textPri, fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            if (_loading)
              Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green))),

            // ── EMPTY STATE ──
            if (!_loading && _pending.isEmpty && _sent.isEmpty && _matches.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: borderCol) : null,
                  boxShadow: [
                    if (Theme.of(context).brightness == Brightness.light)
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(children: [
                  Icon(Icons.people_outline_rounded, size: 48, color: textMut.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No connections yet', style: context.textTheme.displaySmall!.copyWith(color: textPri, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Plan a new trip to start discovering and connecting with matching companions.', 
                       style: context.textTheme.bodyMedium!.copyWith(color: textSec, height: 1.4), textAlign: TextAlign.center),
                ]),
              ),

            // ── PENDING REQUESTS ──
            if (!_loading && _pending.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
                child: Text('REQUESTS', style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ),
              ...List.generate(_pending.length, (i) {
                final req = _pending[i];
                final s = req['sender'] ?? {};
                final d = req['trip']?['destination'] ?? {};
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: borderCol) : null,
                    boxShadow: [
                      if (Theme.of(context).brightness == Brightness.light)
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: _c(i).withValues(alpha: isDark ? 0.2 : 0.08), borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.center,
                        child: Text((s['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _c(i), fontFamily: 'Playfair Display')),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s['fullName'] ?? '', style: context.textTheme.labelLarge!.copyWith(color: textPri, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('${d['name'] ?? 'Trip'} • ${s['travelStyle'] ?? 'Explorer'}', style: context.textTheme.bodySmall!.copyWith(color: textSec, fontSize: 12)),
                      ])),
                    ]),
                    if (req['message'] != null && req['message'].toString().trim().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 14, bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: bgMuted, borderRadius: BorderRadius.circular(12)),
                        child: Text('"${req['message']}"', style: context.textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic, color: textPri, height: 1.4)),
                      ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: GestureDetector(
                        onTap: () => _reject(req['id']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(color: bgPage, border: Border.all(color: borderCol), borderRadius: BorderRadius.circular(14)),
                          alignment: Alignment.center,
                          child: Text('Decline', style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: textSec, fontSize: 13)),
                        ),
                      )),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: GestureDetector(
                        onTap: () => _accept(req['id']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(color: textPri, borderRadius: BorderRadius.circular(14)),
                          alignment: Alignment.center,
                          child: Text("Accept", style: TextStyle(color: bgPage, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      )),
                    ]),
                  ]),
                );
              }),
              const SizedBox(height: 16),
            ],

            // ── SENT REQUESTS ──
            if (!_loading && _sent.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
                child: Text('SENT REQUESTS', style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ),
              ...List.generate(_sent.length, (i) {
                final req = _sent[i];
                final r = req['receiver'] ?? {};
                final d = req['trip']?['destination'] ?? {};
                final st = req['status'] ?? 'PENDING';
                final isPending = st == 'PENDING';
                final sc = st == 'ACCEPTED' ? context.colors.green : st == 'REJECTED' ? context.colors.rose : textSec;
                return Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: bgMuted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: borderCol) : null,
                  ),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: borderCol.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
                      alignment: Alignment.center,
                      child: Text((r['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPri, fontFamily: 'Playfair Display')),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r['fullName'] ?? '', style: context.textTheme.labelLarge!.copyWith(fontSize: 14, color: textPri)),
                      const SizedBox(height: 2),
                      Text('${d['name'] ?? ''}', style: context.textTheme.bodySmall!.copyWith(color: textSec, fontSize: 12)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: sc.withValues(alpha: isDark ? 0.2 : 0.08), borderRadius: BorderRadius.circular(10)),
                      child: Text(isPending ? 'Pending' : st == 'ACCEPTED' ? 'Accepted' : 'Declined', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sc)),
                    ),
                  ]),
                );
              }),
              const SizedBox(height: 16),
            ],

            // ── MATCHED ──
            if (!_loading && _matches.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
                child: Text('CONNECTIONS', style: TextStyle(fontSize: 11, color: textPri, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ),
              ...List.generate(_matches.length, (i) {
                final m = _matches[i];
                final o = m['otherUser'] ?? {};
                final d = m['trip']?['destination'] ?? {};
                final cv = m['conversation'];
                return GestureDetector(
                  onTap: () { if (cv?['id'] != null) context.push('/chat/${cv['id']}'); },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: borderCol) : Border.all(color: borderCol.withValues(alpha: 0.5)),
                      boxShadow: [
                        if (Theme.of(context).brightness == Brightness.light)
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: _c(i).withValues(alpha: isDark ? 0.2 : 0.08), borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.center,
                        child: Text((o['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _c(i), fontFamily: 'Playfair Display')),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o['fullName'] ?? '', style: context.textTheme.labelLarge!.copyWith(color: textPri, fontSize: 15)),
                        const SizedBox(height: 4),
                        if (cv?['lastMessage'] != null)
                          Text(cv['lastMessage'], style: context.textTheme.bodyMedium!.copyWith(color: textMut, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)
                        else
                          Text('Connected for ${d['name'] ?? 'trip'}', style: context.textTheme.bodySmall!.copyWith(color: textSec, fontSize: 12)),
                      ])),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: bgPage, border: Border.all(color: borderCol), borderRadius: BorderRadius.circular(12)),
                        child: Text('Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
                      ),
                    ]),
                  ),
                );
              }),
            ],

          ]),
        )),

        const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 2)),
      ]),
    );
  }
}