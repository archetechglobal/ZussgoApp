import 'package:flutter/material.dart';

/// ZussGo Icon System
/// Replaces ALL emoji UI icons with proper Material Icons.
/// Content emojis (destination labels like 🌴 for Goa) stay — those are data, not UI.
class ZussIcons {
  ZussIcons._();

  // ── Nav ──
  static const IconData home = Icons.home_rounded;
  static const IconData discover = Icons.explore_rounded;
  static const IconData rewards = Icons.stars_rounded;
  static const IconData chat = Icons.chat_bubble_rounded;
  static const IconData profile = Icons.person_rounded;

  // ── Actions ──
  static const IconData search = Icons.search_rounded;
  static const IconData notification = Icons.notifications_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData send = Icons.send_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData edit = Icons.edit_rounded;

  // ── Travel ──
  static const IconData location = Icons.location_on_rounded;
  static const IconData map = Icons.map_rounded;
  static const IconData compass = Icons.explore_rounded;
  static const IconData mountain = Icons.terrain_rounded;
  static const IconData globe = Icons.public_rounded;

  // ── Social ──
  static const IconData handshake = Icons.handshake_rounded;
  static const IconData wave = Icons.waving_hand_rounded;
  static const IconData group = Icons.group_rounded;
  static const IconData verified = Icons.verified_rounded;
  static const IconData shield = Icons.shield_rounded;
  static const IconData id = Icons.badge_rounded;
  static const IconData flag = Icons.flag_rounded;

  // ── Rewards ──
  static const IconData star = Icons.star_rounded;
  static const IconData trophy = Icons.emoji_events_rounded;
  static const IconData gift = Icons.card_giftcard_rounded;
  static const IconData bolt = Icons.bolt_rounded;
  static const IconData cashback = Icons.payments_rounded;
  static const IconData badge = Icons.military_tech_rounded;

  // ── Status ──
  static const IconData trending = Icons.trending_up_rounded;
  static const IconData fire = Icons.local_fire_department_rounded;

  // ── Settings ──
  static const IconData settings = Icons.settings_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData sos = Icons.sos_rounded;
  static const IconData trips = Icons.luggage_rounded;
}

/// Icon with optional tinted background pill.
class ZussIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? bgColor;
  final double? bgSize;
  final double bgRadius;

  const ZussIcon(this.icon, {super.key, this.size = 20, this.color, this.bgColor, this.bgSize, this.bgRadius = 11});

  @override
  Widget build(BuildContext context) {
    final w = Icon(icon, size: size, color: color);
    if (bgColor == null) return w;
    final s = bgSize ?? size + 16;
    return Container(
      width: s, height: s,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(bgRadius)),
      alignment: Alignment.center,
      child: w,
    );
  }
}