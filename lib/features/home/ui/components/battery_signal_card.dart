import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/tactical_theme.dart';

class BatterySignalCard extends StatelessWidget {
  const BatterySignalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return TacticalTheme.glassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.battery_charging_full,
                color: TacticalTheme.neonGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'POWER',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TacticalTheme.neonGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: TacticalTheme.surfaceDark,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.85,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TacticalTheme.neonGreen,
                      TacticalTheme.neonAmber,
                      TacticalTheme.neonRed,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '85%',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TacticalTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.wifi,
                color: TacticalTheme.neonCyan,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'SIGNAL',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TacticalTheme.neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _signalBar(true, true, true),
              const SizedBox(width: 4),
              _signalBar(true, true, false),
              const SizedBox(width: 4),
              _signalBar(true, false, false),
              const SizedBox(width: 4),
              _signalBar(false, false, false),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'MESH NETWORK',
            style: GoogleFonts.rajdhani(
              fontSize: 10,
              color: TacticalTheme.neonCyan,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _signalBar(bool isActive, bool isTall, bool isWide) {
    return Container(
      width: isWide ? 12 : 8,
      height: isTall ? 24 : 16,
      decoration: BoxDecoration(
        color: isActive ? TacticalTheme.neonCyan : TacticalTheme.surfaceGlass,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
