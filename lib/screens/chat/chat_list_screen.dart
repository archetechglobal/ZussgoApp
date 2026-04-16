import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/zuss_icons.dart';
import '../../config/animations.dart';
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
      if (r["success"] == true) {
        _convos = List<Map<String, dynamic>>.from(r["data"] ?? []);
        // Sort: unread first, then by lastMessageAt
        _convos.sort((a, b) {
          final aUnread = (a['unreadCount'] as num?)?.toInt() ?? 0;
          final bUnread = (b['unreadCount'] as num?)?.toInt() ?? 0;
          if (aUnread > 0 && bUnread == 0) return -1;
          if (aUnread == 0 && bUnread > 0) return 1;
          final aTime = a['lastMessageAt'] ?? '';
          final bTime = b['lastMessageAt'] ?? '';
          return bTime.compareTo(aTime);
        });
      }
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
    final unreadCount = _convos.where((cv) => ((cv['unreadCount'] as num?)?.toInt() ?? 0) > 0).length;

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
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Messages', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: c.text)),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(12)),
                          child: Text('$unreadCount new', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: c.primary)),
                        ),
                    ]),
                    const SizedBox(height: 4),
                    Text('Your travel conversations', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary)),
                    const SizedBox(height: 16),

                    // Search
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
                      child: Row(children: [
                        Icon(ZussIcons.search, size: 16, color: c.muted.withValues(alpha: 0.4)),
                        const SizedBox(width: 10),
                        Text('Search messages…', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted)),
                      ]),
                    ),
                    const SizedBox(height: 8),
                  ]),
                ).zussHero(delay: 0),

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
                        final isUnread = unread > 0;

                        return GestureDetector(
                          onTap: () async {
                            await context.push('/chat/${conv['conversationId']}');
                            _load();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              // Instagram-style: unread messages get a subtle tinted background
                              color: isUnread ? c.primarySoft.withValues(alpha: 0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              // Unread gets a left accent border
                              border: isUnread ? Border(
                                left: BorderSide(color: c.primary, width: 3),
                              ) : null,
                            ),
                            child: Row(
                              children: [
                                // Avatar with unread dot
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    _ChatAvatar(photoUrl: o['profilePhotoUrl'], name: o['fullName'] ?? 'U'),
                                    // Unread indicator dot on avatar (like Instagram green dot)
                                    if (isUnread)
                                      Positioned(
                                        bottom: 0, right: 0,
                                        child: Container(
                                          width: 14, height: 14,
                                          decoration: BoxDecoration(
                                            color: c.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: c.bg, width: 2.5),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 14),

                                // Body
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(child: Text(
                                          o['fullName'] ?? 'Traveler',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                            color: c.text,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                        Text(
                                          _timeAgo(conv['lastMessageAt']),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: isUnread ? c.primary : c.muted,
                                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Expanded(child: Text(
                                        hasMsg ? conv['lastMessage'] : 'Say hello!',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: isUnread ? c.text : c.muted,
                                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                                          fontStyle: hasMsg ? FontStyle.normal : FontStyle.italic,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                      if (isUnread) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          constraints: const BoxConstraints(minWidth: 22), height: 22,
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          decoration: BoxDecoration(
                                            color: c.primary,
                                            borderRadius: BorderRadius.circular(11),
                                            boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 6)],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text('$unread', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                                        ),
                                      ],
                                    ]),
                                    if (dest != null) ...[
                                      const SizedBox(height: 4),
                                      Row(mainAxisSize: MainAxisSize.min, children: [
                                        Icon(ZussIcons.location, size: 10, color: c.muted),
                                        const SizedBox(width: 3),
                                        Text(dest['name'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted)),
                                      ]),
                                    ],
                                  ],
                                )),
                              ],
                            ),
                          ),
                        ).zussEntrance(index: i);
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
        Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c.primary.withValues(alpha: 0.08), Colors.transparent]))),
            Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: c.card, border: Border.all(color: c.border, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]),
                child: Icon(ZussIcons.chat, size: 32, color: c.primary.withValues(alpha: 0.6))),
            Positioned(top: 15, right: 20, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: c.goldSoft, shape: BoxShape.circle, border: Border.all(color: c.goldMid)))),
            Positioned(bottom: 20, left: 15, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: c.lavenderSoft, shape: BoxShape.circle))),
          ],
        ).zussPop(delay: 100),
        const SizedBox(height: 24),
        Text('No messages yet', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: c.text)).zussEntrance(index: 0, baseDelay: 200),
        const SizedBox(height: 8),
        Text('Find a travel companion and\nstart planning your next adventure', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted, height: 1.6), textAlign: TextAlign.center).zussEntrance(index: 1, baseDelay: 200),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => context.go('/search'),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(ZussIcons.compass, size: 16, color: Colors.white), const SizedBox(width: 8),
                Text('Find Companions', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              ])),
        ).zussEntrance(index: 2, baseDelay: 200),
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(colors: [c.primary.withValues(alpha: 0.3), c.card])),
      clipBehavior: Clip.hardEdge,
      child: photoUrl != null ? Image.network(photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initial(c)) : _initial(c),
    );
  }

  Widget _initial(ZussGoColors c) => Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: c.primary)));
}