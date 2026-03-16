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
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId == null) { setState(() => _isLoading = false); return; }

    final result = await ApiService.getConversations(userId);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result["success"] == true && result["data"] != null) {
          _conversations = List<Map<String, dynamic>>.from(result["data"]);
        }
      });
    }
  }

  Color _userColor(int index) {
    final colors = [ZussGoTheme.rose, ZussGoTheme.sky, ZussGoTheme.sage, ZussGoTheme.lavender, ZussGoTheme.amber];
    return colors[index % colors.length];
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Text('Messages', style: ZussGoTheme.displayMedium),
                  const SizedBox(height: 4),
                  Text('Chat with your travel companions', style: ZussGoTheme.bodySmall),
                ],
              ),
            ),

            const Divider(color: ZussGoTheme.borderDefault, height: 1),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.amber.withValues(alpha: 0.5)))
                  : _conversations.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('💬', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text('No conversations yet', style: ZussGoTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text(
                      'When you match with a traveler, your conversation will appear here.',
                      style: ZussGoTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => context.go('/search'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(14)),
                        child: Text('Find Travelers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadConversations,
                color: ZussGoTheme.amber,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _conversations.length,
                  itemBuilder: (context, i) {
                    final convo = _conversations[i];
                    final other = convo['otherUser'] ?? {};
                    final trip = convo['trip'] ?? {};
                    final dest = trip['destination'] ?? {};
                    final color = _userColor(i);
                    final hasMessage = convo['lastMessage'] != null;

                    return GestureDetector(
                      onTap: () async {
                        await context.push('/chat/${convo['conversationId']}');
                        // Reload when coming back from chat
                        _loadConversations();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: ZussGoTheme.borderDefault)),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: color.withValues(alpha: 0.15)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                (other['fullName'] ?? 'U')[0].toUpperCase(),
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color, fontFamily: 'Playfair Display'),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Name + last message
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(other['fullName'] ?? 'Unknown', style: ZussGoTheme.labelBold),
                                      if (convo['lastMessageAt'] != null)
                                        Text(_formatTime(convo['lastMessageAt']), style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    hasMessage ? convo['lastMessage'] : 'Say hello! 👋',
                                    style: ZussGoTheme.bodySmall.copyWith(
                                      color: hasMessage ? ZussGoTheme.textSecondary : ZussGoTheme.textMuted,
                                      fontStyle: hasMessage ? FontStyle.normal : FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // Trip badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ZussGoTheme.bgCard,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: ZussGoTheme.borderDefault),
                                    ),
                                    child: Text(
                                      '${dest['emoji'] ?? '✈️'} ${dest['name'] ?? 'Trip'}',
                                      style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}