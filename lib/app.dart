import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';

class ZussGoApp extends StatelessWidget {
  const ZussGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZussGo',
      debugShowCheckedModeBanner: false,
      theme: ZussGoTheme.darkTheme,
      routerConfig: router,
    );
  }

}
