import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  const ChatScreen({super.key, required this.matchId});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgC = TextEditingController();
  final _scrollC = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  String? _userId, _otherName, _otherInitial, _tripInfo;
  bool _loading = true, _typing = false;
  StreamSubscription? _msgSub, _typeSub;
  Timer? _typeTimer;

  @override
  void initState() { super.initState(); _init(); }
  @override
  void dispose() { _msgC.dispose(); _scrollC.dispose(); _msgSub?.cancel(); _typeSub?.cancel(); _typeTimer?.cancel(); super.dispose(); }

  Future<void> _init() async {
    final u = await AuthService.getSavedUser(); _userId = u?['userId']; if (_userId == null) return;
    await ChatService.connect(_userId!);
    ChatService.markRead(widget.matchId);

    _msgSub = ChatService.onMessage.listen((msg) {
      if (!mounted) return;
      final cid = msg['conversationId'] ?? msg['conversation']?['id'];
      if (cid != widget.matchId) return;
      if (msg['senderId'] == _userId) { setState(() { _messages.removeWhere((m) => m['id'].toString().startsWith('temp_')); _messages.add(msg); }); }
      else { setState(() => _messages.add(msg)); ChatService.markRead(widget.matchId); }
      _scrollDown();
    });

    _typeSub = ChatService.onTyping.listen((d) {
      if (d['conversationId'] == widget.matchId && d['userId'] != _userId) {
        if (mounted) { setState(() => _typing = true); _typeTimer?.cancel(); _typeTimer = Timer(const Duration(seconds: 2), () { if (mounted) setState(() => _typing = false); }); }
      }
    });

    final cr = await ApiService.getConversations(_userId!);
    if (cr["success"] == true) {
      for (var c in List<Map<String, dynamic>>.from(cr["data"] ?? [])) {
        if (c['conversationId'] == widget.matchId) {
          final o = c['otherUser'] ?? {}; _otherName = o['fullName'] ?? 'Traveler'; _otherInitial = (_otherName ?? 'T')[0].toUpperCase();
          final d = c['trip']?['destination']; if (d != null) _tripInfo = '${d['emoji'] ?? ''} ${d['name'] ?? ''}'; break;
        }
      }
    }

    final mr = await ApiService.getMessages(widget.matchId, _userId!);
    if (mr["success"] == true) _messages = List<Map<String, dynamic>>.from(mr["data"] ?? []).reversed.toList();
    if (mounted) { setState(() => _loading = false); _scrollDown(); }
  }

  void _scrollDown() { Future.delayed(const Duration(milliseconds: 120), () { if (_scrollC.hasClients) _scrollC.animateTo(_scrollC.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut); }); }

  void _send() {
    final txt = _msgC.text.trim(); if (txt.isEmpty || _userId == null) return; _msgC.clear();
    setState(() { _messages.add({'id': 'temp_${DateTime.now().millisecondsSinceEpoch}', 'senderId': _userId, 'content': txt, 'createdAt': DateTime.now().toIso8601String(), 'sender': {'id': _userId, 'fullName': 'You'}}); });
    _scrollDown(); ChatService.sendMessage(widget.matchId, txt);
  }

  String _fmtTime(String? d) { if (d == null) return ''; final dt = DateTime.tryParse(d); if (dt == null) return ''; final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour); return '$h:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}'; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SafeArea(child: Column(children: [
      // Header
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ZussGoTheme.borderDefault))),
          child: Row(children: [
            GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 18))),
            const SizedBox(width: 10),
            Container(width: 38, height: 38, decoration: BoxDecoration(color: ZussGoTheme.sky.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center, child: Text(_otherInitial ?? '?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ZussGoTheme.sky, fontFamily: 'Playfair Display'))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(_otherName ?? '...', style: ZussGoTheme.labelBold.copyWith(fontSize: 13)), const SizedBox(width: 4), Container(width: 6, height: 6, decoration: const BoxDecoration(color: ZussGoTheme.mint, shape: BoxShape.circle))]),
              if (_typing) Text('typing...', style: TextStyle(fontSize: 10, color: ZussGoTheme.green, fontStyle: FontStyle.italic))
              else if (_tripInfo != null) Text(_tripInfo!, style: ZussGoTheme.bodySmall),
            ])),
          ])),

      // Trip banner
      if (_tripInfo != null) Container(margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [const Text('✈️', style: TextStyle(fontSize: 13)), const SizedBox(width: 6), Text('Traveling together to $_tripInfo', style: TextStyle(fontSize: 11, color: ZussGoTheme.green, fontWeight: FontWeight.w500))])),

      // Messages
      Expanded(child: _loading ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green))
          : _messages.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('👋', style: TextStyle(fontSize: 36)), const SizedBox(height: 10), Text('Say hello!', style: ZussGoTheme.displaySmall), Text('Start planning together', style: ZussGoTheme.bodySmall)]))
          : ListView.builder(controller: _scrollC, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), itemCount: _messages.length, itemBuilder: (_, i) {
        final m = _messages[i]; final isMe = m['senderId'] == _userId; final isTemp = m['id'].toString().startsWith('temp_');
        return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75), margin: const EdgeInsets.only(bottom: 8),
                child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isMe ? ZussGoTheme.gradientPrimary : null,
                        color: isMe ? null : ZussGoTheme.bgMuted,
                        borderRadius: BorderRadius.only(topLeft: const Radius.circular(18), topRight: const Radius.circular(18), bottomLeft: Radius.circular(isMe ? 18 : 4), bottomRight: Radius.circular(isMe ? 4 : 18)),
                        boxShadow: isMe ? [BoxShadow(color: ZussGoTheme.green.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))] : null,
                      ),
                      child: Text(m['content'] ?? '', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: isMe ? Colors.white : ZussGoTheme.textPrimary, height: 1.45))),
                  const SizedBox(height: 3),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_fmtTime(m['createdAt']), style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted)),
                    if (isMe && !isTemp) ...[const SizedBox(width: 3), Icon(Icons.done_rounded, size: 11, color: ZussGoTheme.green.withValues(alpha: 0.5))],
                    if (isMe && isTemp) ...[const SizedBox(width: 3), Icon(Icons.schedule_rounded, size: 9, color: ZussGoTheme.textMuted.withValues(alpha: 0.5))],
                  ]),
                ])));
      })),

      // Input
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: const BoxDecoration(border: Border(top: BorderSide(color: ZussGoTheme.borderDefault))),
          child: Row(children: [
            Expanded(child: TextField(controller: _msgC,
                decoration: InputDecoration(hintText: 'Type a message...', hintStyle: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textMuted), filled: true, fillColor: ZussGoTheme.bgMuted,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), onChanged: (_) => ChatService.sendTyping(widget.matchId), onSubmitted: (_) => _send(), textInputAction: TextInputAction.send)),
            const SizedBox(width: 8),
            GestureDetector(onTap: _send, child: Container(width: 42, height: 42, decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: ZussGoTheme.green.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 18))),
          ])),
    ])));
  }
}