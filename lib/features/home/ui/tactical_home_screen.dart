import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/tactical_theme.dart';
import 'components/network_radar.dart';
import 'components/battery_signal_card.dart';
import 'components/active_rescuers_card.dart';
import 'components/recent_messages_card.dart';

class TacticalHomeScreen extends StatefulWidget {
  const TacticalHomeScreen({super.key});

  @override
  State<TacticalHomeScreen> createState() => _TacticalHomeScreenState();
}

class _TacticalHomeScreenState extends State<TacticalHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gridItems = [
      {'widget': NetworkRadar(pulseAnimation: _pulseAnimation, peerCount: 3), 'flex': 2},
      {'widget': BatterySignalCard(), 'flex': 1},
      {'widget': ActiveRescuersCard(), 'flex': 2},
      {'widget': RecentMessagesCard(), 'flex': 2},
    ];

    return Scaffold(
      backgroundColor: TacticalTheme.voidBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: gridItems[0]['widget'] as Widget,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: gridItems[1]['widget'] as Widget,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: gridItems[2]['widget'] as Widget,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: gridItems[3]['widget'] as Widget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
