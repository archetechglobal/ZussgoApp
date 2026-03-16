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
  final String matchId; // conversationId
  const ChatScreen({super.key, required this.matchId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  String? _userId;
  String? _otherUserName;
  String? _otherUserInitial;
  String? _tripInfo;
  Color _otherUserColor = ZussGoTheme.sky;
  bool _isLoading = true;
  bool _isTyping = false;
  StreamSubscription? _messageSub;
  StreamSubscription? _typingSub;
  Timer? _typingTimer;

  // Track sent message IDs to prevent duplicates
  final Set<String> _sentTempIds = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageSub?.cancel();
    _typingSub?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final user = await AuthService.getSavedUser();
    _userId = user?['userId'];
    if (_userId == null) return;

    // Connect WebSocket if not already
    await ChatService.connect(_userId!);

    // Mark messages as read
    ChatService.markRead(widget.matchId);

    // Listen for new messages from WebSocket
    _messageSub = ChatService.onMessage.listen((msg) {
      if (!mounted) return;

      final msgConvoId = msg['conversationId'] ?? msg['conversation']?['id'];
      if (msgConvoId != widget.matchId) return;

      // If this is confirmation of our sent message, replace the temp message
      if (msg['senderId'] == _userId) {
        setState(() {
          // Remove any temp messages from the same sender
          _messages.removeWhere((m) => m['id'].toString().startsWith('temp_'));
          // Add the confirmed message
          _messages.add(msg);
        });
      } else {
        // New message from the other person
        setState(() => _messages.add(msg));
        ChatService.markRead(widget.matchId);
      }

      _scrollToBottom();
    });

    // Listen for typing indicators
    _typingSub = ChatService.onTyping.listen((data) {
      if (data['conversationId'] == widget.matchId && data['userId'] != _userId) {
        if (mounted) {
          setState(() => _isTyping = true);
          _typingTimer?.cancel();
          _typingTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) setState(() => _isTyping = false);
          });
        }
      }
    });

    // Load conversation info
    final convoResult = await ApiService.getConversations(_userId!);
    if (convoResult["success"] == true && convoResult["data"] != null) {
      final convos = List<Map<String, dynamic>>.from(convoResult["data"]);
      for (var c in convos) {
        if (c['conversationId'] == widget.matchId) {
          final other = c['otherUser'] ?? {};
          _otherUserName = other['fullName'] ?? 'Traveler';
          _otherUserInitial = (_otherUserName ?? 'T')[0].toUpperCase();
          final dest = c['trip']?['destination'];
          if (dest != null) _tripInfo = '${dest['emoji'] ?? ''} ${dest['name'] ?? ''}';
          break;
        }
      }
    }

    // Load existing messages
    final msgResult = await ApiService.getMessages(widget.matchId, _userId!);
    if (msgResult["success"] == true && msgResult["data"] != null) {
      _messages = List<Map<String, dynamic>>.from(msgResult["data"]).reversed.toList();
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _userId == null) return;

    _messageController.clear();

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    _sentTempIds.add(tempId);

    // Optimistic update — show message immediately
    setState(() {
      _messages.add({
        'id': tempId,
        'senderId': _userId,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
        'sender': {'id': _userId, 'fullName': 'You'},
      });
    });
    _scrollToBottom();

    // Send via WebSocket (backend will confirm via message_sent event)
    ChatService.sendMessage(widget.matchId, content);
  }

  void _handleTyping() {
    ChatService.sendTyping(widget.matchId);
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZussGoTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ZussGoTheme.bgPrimary,
                border: Border(bottom: BorderSide(color: ZussGoTheme.borderDefault)),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _otherUserColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _otherUserColor.withValues(alpha: 0.15)),
                  ),
                  alignment: Alignment.center,
                  child: Text(_otherUserInitial ?? '?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _otherUserColor, fontFamily: 'Playfair Display')),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(_otherUserName ?? 'Loading...', style: ZussGoTheme.labelBold),
                    const SizedBox(width: 6),
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: ZussGoTheme.mint, shape: BoxShape.circle)),
                  ]),
                  if (_isTyping)
                    Text('typing...', style: TextStyle(fontSize: 11, color: ZussGoTheme.mint, fontStyle: FontStyle.italic))
                  else if (_tripInfo != null)
                    Text(_tripInfo!, style: ZussGoTheme.bodySmall),
                ])),
              ]),
            ),

            // ── TRIP BANNER ──
            if (_tripInfo != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: ZussGoTheme.amber.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ZussGoTheme.amber.withValues(alpha: 0.08)),
                ),
                child: Row(children: [
                  Text('✈️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Traveling together to $_tripInfo', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.amber))),
                ]),
              ),

            // ── MESSAGES ──
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.amber.withValues(alpha: 0.5)))
                  : _messages.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('👋', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text('Say hello!', style: ZussGoTheme.displaySmall),
                const SizedBox(height: 6),
                Text("Start planning your trip together", style: ZussGoTheme.bodySmall),
              ]))
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isMe = m['senderId'] == _userId;
                  final isTemp = m['id'].toString().startsWith('temp_');

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          // Message bubble
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isMe ? ZussGoTheme.gradientPrimary : null,
                              color: isMe ? null : ZussGoTheme.bgSecondary,
                              border: isMe ? null : Border.all(color: ZussGoTheme.borderDefault),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(isMe ? 20 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 20),
                              ),
                              boxShadow: isMe
                                  ? [BoxShadow(color: ZussGoTheme.amber.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Text(
                              m['content'] ?? '',
                              style: ZussGoTheme.bodyMedium.copyWith(
                                color: isMe ? Colors.white : ZussGoTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),

                          // Time + status
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_formatTime(m['createdAt']), style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted)),
                              if (isMe && isTemp) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.schedule_rounded, size: 10, color: ZussGoTheme.textMuted.withValues(alpha: 0.5)),
                              ] else if (isMe) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.done_rounded, size: 12, color: ZussGoTheme.mint.withValues(alpha: 0.6)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── TYPING INDICATOR ──
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 4),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ZussGoTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ZussGoTheme.borderDefault),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _TypingDot(delay: 0),
                      const SizedBox(width: 4),
                      _TypingDot(delay: 200),
                      const SizedBox(width: 4),
                      _TypingDot(delay: 400),
                    ]),
                  ),
                ]),
              ),

            // ── INPUT ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ZussGoTheme.bgPrimary,
                border: Border(top: BorderSide(color: ZussGoTheme.borderDefault)),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textMuted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: ZussGoTheme.borderDefault)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: ZussGoTheme.borderDefault)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: ZussGoTheme.amber.withValues(alpha: 0.3))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      filled: true,
                      fillColor: ZussGoTheme.bgSecondary,
                    ),
                    style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                    onChanged: (_) => _handleTyping(),
                    onSubmitted: (_) => _handleSend(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: ZussGoTheme.gradientPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: ZussGoTheme.amber.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated typing dot
class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(width: 6, height: 6, decoration: BoxDecoration(color: ZussGoTheme.textMuted, shape: BoxShape.circle)),
        );
      },
    );
  }
}