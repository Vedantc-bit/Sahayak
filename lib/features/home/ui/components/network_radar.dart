import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../../../theme/tactical_theme.dart';

class NetworkRadar extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final int peerCount;
  
  const NetworkRadar({
    super.key,
    required this.pulseAnimation,
    required this.peerCount,
  });

  @override
  Widget build(BuildContext context) {
    return TacticalTheme.glassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: TacticalTheme.neonCyan,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'NETWORK STATUS',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TacticalTheme.neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radar circles
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: TacticalTheme.surfaceGlass,
                            width: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: TacticalTheme.surfaceGlass,
                            width: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: TacticalTheme.surfaceGlass,
                            width: 1,
                          ),
                        ),
                      ),
                      // Pulsing center
                      Transform.scale(
                        scale: pulseAnimation.value,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TacticalTheme.neonCyan,
                            boxShadow: [
                              BoxShadow(
                                color: TacticalTheme.neonCyan.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Peer indicators
                      ...List.generate(3, (index) {
                        final angle = (index * 120) * (3.14159 / 180);
                        final radius = 80.0;
                        final x = radius * cos(angle);
                        final y = radius * sin(angle);
                        
                        return Positioned(
                          left: 100 + x - 6,
                          top: 100 + y - 6,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TacticalTheme.neonGreen,
                              boxShadow: [
                                BoxShadow(
                                  color: TacticalTheme.neonGreen.withOpacity(0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  '$peerCount',
                  style: GoogleFonts.orbitron(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: TacticalTheme.neonCyan,
                  ),
                ),
                Text(
                  'PEERS NEARBY',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: TacticalTheme.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: TacticalTheme.neonCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: TacticalTheme.neonCyan.withOpacity(0.3),
              ),
            ),
            child: Text(
              'MESH ACTIVE',
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                color: TacticalTheme.neonCyan,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
