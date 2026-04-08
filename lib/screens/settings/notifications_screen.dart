import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _convos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser();
    final uid = u?['userId'];
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final r = await Future.wait([
      ApiService.getPendingRequests(uid),
      ApiService.getConversations(uid),
    ]);

    if (mounted) {
      setState(() {
        _loading = false;
        if (r[0]['success'] == true) _requests = List<Map<String, dynamic>>.from(r[0]['data'] ?? []);
        if (r[1]['success'] == true) {
          final allConvos = List<Map<String, dynamic>>.from(r[1]['data'] ?? []);
          // Filter to show conversations that actually have messages to act as recent message notifications
          _convos = allConvos.where((c) => c['lastMessage'] != null).toList();
          // Sort conversations by newest first
          _convos.sort((a, b) {
            final aTime = DateTime.tryParse(a['lastMessageAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = DateTime.tryParse(b['lastMessageAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
        }
      });
      // Mark as seen once we've successfully loaded the list
      context.read<NotificationService>().markAsSeen();
    }
  }

  Color _c(int i) {
    final cs = [context.colors.sky, context.colors.amber, context.colors.rose, context.colors.green, ZussGoTheme.lavender];
    return cs[i % cs.length];
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
    final bgPage = ZussGoTheme.scaffoldBg(context);
    final textPri = ZussGoTheme.primaryText(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPri),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications', style: context.textTheme.displaySmall!.copyWith(color: textPri, fontSize: 18)),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: context.colors.green, strokeWidth: 2))
          : _requests.isEmpty && _convos.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: context.colors.green,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                    children: [
                      if (_requests.isNotEmpty) ...[
                        Text('MATCH REQUESTS', style: TextStyle(fontSize: 11, color: context.colors.green, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        ...List.generate(_requests.length, (i) => _buildRequestTile(_requests[i], i, isDark)),
                        const SizedBox(height: 24),
                      ],
                      if (_convos.isNotEmpty) ...[
                        Text('RECENT MESSAGES', style: TextStyle(fontSize: 11, color: context.colors.sky, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        ...List.generate(_convos.length, (i) => _buildConvoTile(_convos[i], i, isDark)),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: context.colors.sky.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.notifications_active_rounded, size: 40, color: context.colors.sky),
            ),
            const SizedBox(height: 20),
            Text('You\'re all caught up!', style: context.textTheme.displaySmall!.copyWith(color: ZussGoTheme.primaryText(context))),
            const SizedBox(height: 10),
            Text('No new notifications right now. Check back later for updates on your trips and matches.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.mutedText(context))
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestTile(Map<String, dynamic> req, int i, bool isDark) {
    final s = req['sender'] ?? {};
    final d = req['trip']?['destination'] ?? {};
    return GestureDetector(
      onTap: () => context.push('/matches'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ZussGoTheme.cardBg(context),
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: ZussGoTheme.border(context)) : null,
          boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
           Container(
             width: 48, height: 48,
             decoration: BoxDecoration(color: _c(i).withValues(alpha: isDark ? 0.2 : 0.08), borderRadius: BorderRadius.circular(16)),
             alignment: Alignment.center,
             child: Icon(Icons.person_add_rounded, color: _c(i), size: 22),
           ),
           const SizedBox(width: 14),
           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
             RichText(text: TextSpan(children: [
               TextSpan(text: '${s['fullName'] ?? 'Someone'} ', style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700, color: ZussGoTheme.primaryText(context))),
               TextSpan(text: 'sent you a trip request for ', style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.secondaryText(context))),
               TextSpan(text: '${d['name'] ?? 'a destination'}.', style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.primaryText(context))),
             ])),
             const SizedBox(height: 6),
             Text(_timeAgo(req['createdAt']), style: context.textTheme.bodySmall!.copyWith(color: ZussGoTheme.mutedText(context), fontSize: 11)),
           ])),
        ]),
      ),
    );
  }

  Widget _buildConvoTile(Map<String, dynamic> c, int i, bool isDark) {
    final o = c['otherUser'] ?? {};
    return GestureDetector(
      onTap: () => context.push('/chat/${c['conversationId']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ZussGoTheme.cardBg(context),
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: ZussGoTheme.border(context)) : null,
          boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
           Container(
             width: 48, height: 48,
             decoration: BoxDecoration(color: context.colors.sky.withValues(alpha: isDark ? 0.2 : 0.08), borderRadius: BorderRadius.circular(16)),
             alignment: Alignment.center,
             child: Icon(Icons.chat_bubble_rounded, color: context.colors.sky, size: 20),
           ),
           const SizedBox(width: 14),
           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
               Text('${o['fullName'] ?? 'Traveler'} sent a message', style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700, color: ZussGoTheme.primaryText(context))),
               Text(_timeAgo(c['lastMessageAt']), style: context.textTheme.bodySmall!.copyWith(color: ZussGoTheme.mutedText(context), fontSize: 11)),
             ]),
             const SizedBox(height: 4),
             Text('"${c['lastMessage'] ?? ''}"', style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.secondaryText(context), fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
           ])),
        ]),
      ),
    );
  }
}
