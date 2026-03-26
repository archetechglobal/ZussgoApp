import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _convos = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser(); final uid = u?['userId']; if (uid == null) { setState(() => _loading = false); return; }
    final r = await ApiService.getConversations(uid);
    if (mounted) setState(() { _loading = false; if (r["success"] == true) _convos = List<Map<String, dynamic>>.from(r["data"] ?? []); });
  }

  Color _c(int i) { const cs = [ZussGoTheme.rose, ZussGoTheme.sky, ZussGoTheme.amber, ZussGoTheme.lavender, ZussGoTheme.green]; return cs[i % cs.length]; }

  String _timeAgo(String? d) {
    if (d == null) return ''; final dt = DateTime.tryParse(d); if (dt == null) return ''; final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now'; if (diff.inMinutes < 60) return '${diff.inMinutes}m'; if (diff.inHours < 24) return '${diff.inHours}h'; return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(22, 10, 22, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 18))),
        const SizedBox(height: 10), Text('Messages', style: ZussGoTheme.displayMedium), Text('Chat with travel companions', style: ZussGoTheme.bodySmall),
      ])),
      const Divider(color: ZussGoTheme.borderDefault, height: 1),
      Expanded(child: _loading ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green))
          : _convos.isEmpty ? Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('💬', style: TextStyle(fontSize: 40)), const SizedBox(height: 12), Text('No conversations', style: ZussGoTheme.displaySmall), const SizedBox(height: 6),
        Text('Match with travelers to start chatting', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center)])))
          : RefreshIndicator(onRefresh: _load, color: ZussGoTheme.green, child: ListView.builder(padding: const EdgeInsets.symmetric(vertical: 6), itemCount: _convos.length, itemBuilder: (_, i) {
        final c = _convos[i]; final o = c['otherUser'] ?? {}; final d = c['trip']?['destination'] ?? {}; final hasMsg = c['lastMessage'] != null;
        return GestureDetector(onTap: () async { await context.push('/chat/${c['conversationId']}'); _load(); },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ZussGoTheme.borderDefault))),
                child: Row(children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: _c(i).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center, child: Text((o['fullName'] ?? 'U')[0].toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _c(i), fontFamily: 'Playfair Display'))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o['fullName'] ?? '', style: ZussGoTheme.labelBold), if (c['lastMessageAt'] != null) Text(_timeAgo(c['lastMessageAt']), style: ZussGoTheme.bodySmall)]),
                    const SizedBox(height: 2),
                    Text(hasMsg ? c['lastMessage'] : 'Say hello! 👋', style: ZussGoTheme.bodySmall.copyWith(color: hasMsg ? ZussGoTheme.textSecondary : ZussGoTheme.textMuted, fontStyle: hasMsg ? FontStyle.normal : FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(4)),
                        child: Text('${d['emoji'] ?? '✈️'} ${d['name'] ?? 'Trip'}', style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted))),
                  ])),
                ])));
      }))),
    ])));
  }
}