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

  Color _c(int i) { final cs = [context.colors.rose, context.colors.sky, context.colors.amber, ZussGoTheme.lavender, context.colors.green]; return cs[i % cs.length]; }

  String _timeAgo(String? d) {
    if (d == null) return ''; final dt = DateTime.tryParse(d); if (dt == null) return ''; final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now'; if (diff.inMinutes < 60) return '${diff.inMinutes}m'; if (diff.inHours < 24) return '${diff.inHours}h'; return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context), body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(22, 10, 22, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.arrow_back_rounded, color: ZussGoTheme.secondaryText(context), size: 18))),
        SizedBox(height: 10), Text('Messages', style: context.textTheme.displayMedium!.adaptive(context)), Text('Chat with travel companions', style: context.textTheme.bodySmall!.adaptive(context)),
      ])),
      Divider(color: ZussGoTheme.border(context), height: 1),
      Expanded(child: _loading ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green))
          : _convos.isEmpty ? Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.chat_bubble_outline_rounded, size: 44, color: ZussGoTheme.mutedText(context).withValues(alpha: 0.4)), SizedBox(height: 12), Text('No conversations', style: context.textTheme.displaySmall!.adaptive(context)), SizedBox(height: 6),
        Text('Match with travelers to start chatting', style: context.textTheme.bodySmall!.adaptive(context), textAlign: TextAlign.center)])))
          : RefreshIndicator(onRefresh: _load, color: context.colors.green, child: ListView.builder(padding: const EdgeInsets.symmetric(vertical: 6), itemCount: _convos.length, itemBuilder: (_, i) {
        final c = _convos[i]; final o = c['otherUser'] ?? {}; final d = c['trip']?['destination'] ?? {}; final hasMsg = c['lastMessage'] != null;
        return GestureDetector(onTap: () async { await context.push('/chat/${c['conversationId']}'); _load(); },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ZussGoTheme.border(context)))),
                child: Row(children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: _c(i).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center, child: Text((o['fullName'] ?? 'U')[0].toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _c(i), fontFamily: 'Playfair Display'))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o['fullName'] ?? '', style: context.textTheme.labelLarge!.adaptive(context)), if (c['lastMessageAt'] != null) Text(_timeAgo(c['lastMessageAt']), style: context.textTheme.bodySmall!.adaptive(context))]),
                    const SizedBox(height: 2),
                    Text(hasMsg ? c['lastMessage'] : 'Say hello.', style: context.textTheme.bodySmall!.copyWith(color: hasMsg ? ZussGoTheme.textSecondary : context.colors.textMuted, fontStyle: hasMsg ? FontStyle.normal : FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(4)),
                        child: Text('${d['name'] ?? 'Trip'}', style: TextStyle(fontSize: 9, color: ZussGoTheme.mutedText(context)))),
                  ])),
                ])));
      }))),
    ])));
  }
}