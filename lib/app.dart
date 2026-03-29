import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/theme_service.dart';

class ZussGoApp extends StatelessWidget {
  const ZussGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    return MaterialApp.router(
      title: 'ZussGo',
      debugShowCheckedModeBanner: false,
      theme: ZussGoTheme.lightTheme,
      darkTheme: ZussGoTheme.darkTheme,
      themeMode: themeService.mode,
      routerConfig: router,
    );
  }
}