import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/ui/tactical_home_screen.dart';
import 'theme/tactical_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahayak',
      theme: TacticalTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const TacticalHomeScreen(),
    );
  }
}
