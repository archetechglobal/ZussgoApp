import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
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
  String? _userId;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser();
    _userId = u?['userId'];
    if (_userId == null) { setState(() => _loading = false); return; }
    final r = await ApiService.getConversations(_userId!);
    if (mounted) setState(() {
      _loading = false;
      if (r["success"] == true) _convos = List<Map<String, dynamic>>.from(r["data"] ?? []);
    });
  }

  String _timeAgo(String? d) {
    if (d == null) return '';
    final dt = DateTime.tryParse(d);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Messages', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: c.text)),
                    const SizedBox(height: 4),
                    Text('Your travel conversations', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary)),
                    const SizedBox(height: 16),

                    // Search
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        Text('🔍', style: TextStyle(fontSize: 15, color: c.muted.withValues(alpha: 0.4))),
                        const SizedBox(width: 10),
                        Text('Search messages…', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted)),
                      ]),
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),

                // Conversations
                Expanded(
                  child: _loading
                      ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))
                      : _convos.isEmpty
                      ? _buildEmptyState(c)
                      : RefreshIndicator(
                    onRefresh: _load,
                    color: c.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
                      itemCount: _convos.length,
                      itemBuilder: (_, i) {
                        final conv = _convos[i];
                        final o = conv['otherUser'] ?? {};
                        final hasMsg = conv['lastMessage'] != null;
                        final unread = (conv['unreadCount'] as num?)?.toInt() ?? 0;
                        final dest = conv['trip']?['destination'];

                        return GestureDetector(
                          onTap: () async {
                            await context.push('/chat/${conv['conversationId']}');
                            _load();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Row(
                              children: [
                                // Photo avatar
                                _ChatAvatar(photoUrl: o['profilePhotoUrl'], name: o['fullName'] ?? 'U'),
                                const SizedBox(width: 14),

                                // Body
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Flexible(child: Text(o['fullName'] ?? 'Traveler', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w600, color: c.text), overflow: TextOverflow.ellipsis)),
                                    Text(_timeAgo(conv['lastMessageAt']), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: unread > 0 ? c.primary : c.muted, fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w400)),
                                  ]),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Expanded(child: Text(
                                      hasMsg ? conv['lastMessage'] : 'Say hello! 👋',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: unread > 0 ? c.text : c.muted, fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                                          fontStyle: hasMsg ? FontStyle.normal : FontStyle.italic),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    )),
                                    if (unread > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        constraints: const BoxConstraints(minWidth: 20), height: 20,
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(10)),
                                        alignment: Alignment.center,
                                        child: Text('$unread', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                                      ),
                                    ],
                                  ]),
                                  if (dest != null) ...[
                                    const SizedBox(height: 4),
                                    Text('${dest['emoji'] ?? '🗺️'} ${dest['name'] ?? ''}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted)),
                                  ],
                                ])),
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
          const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 3)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ZussGoColors c) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('💬', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('No messages yet', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: c.text)),
        const SizedBox(height: 8),
        Text('When someone accepts your companion\nrequest, you can chat with them here.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted, height: 1.6), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => context.go('/search'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(14)),
            child: Text('Find Companions', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
      ]),
    ));
  }
}

class _ChatAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  const _ChatAvatar({this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [c.primary.withValues(alpha: 0.3), c.card]),
      ),
      clipBehavior: Clip.hardEdge,
      child: photoUrl != null
          ? Image.network(photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initial(c))
          : _initial(c),
    );
  }

  Widget _initial(ZussGoColors c) => Center(
    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: c.primary)),
  );
}