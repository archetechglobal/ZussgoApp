import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/theme_service.dart';

class ZussGoApp extends StatelessWidget {
  const ZussGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // V3: Dark-only design — ignore theme toggle, always dark
    return MaterialApp.router(
      title: 'ZussGo',
      debugShowCheckedModeBanner: false,
      theme: ZussGoTheme.darkTheme,
      darkTheme: ZussGoTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}