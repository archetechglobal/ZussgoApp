import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZussGoTheme.scaffoldBg(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: ZussGoTheme.primaryText(context)),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications', style: context.textTheme.displaySmall!.copyWith(color: ZussGoTheme.primaryText(context), fontSize: 18)),
        centerTitle: true,
      ),
      body: Center(
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
      ),
    );
  }
}
