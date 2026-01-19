import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/tactical_theme.dart';

class ActiveRescuersCard extends StatelessWidget {
  const ActiveRescuersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final rescuers = [
      {'name': 'MED-UNIT-1', 'status': 'ACTIVE', 'distance': '0.3km'},
      {'name': 'MED-UNIT-2', 'status': 'ACTIVE', 'distance': '0.5km'},
      {'name': 'FIRE-TEAM-3', 'status': 'RESPONDING', 'distance': '1.2km'},
      {'name': 'SEARCH-TEAM-4', 'status': 'STANDBY', 'distance': '2.1km'},
    ];

    return TacticalTheme.glassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: TacticalTheme.neonGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ACTIVE RESCUERS',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TacticalTheme.neonGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rescuers.length,
              itemBuilder: (context, index) {
                final rescuer = rescuers[index];
                final isActive = rescuer['status'] == 'ACTIVE';
                final isResponding = rescuer['status'] == 'RESPONDING';
                
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  child: TacticalTheme.chamferedContainer(
                    chamferSize: 6,
                    padding: const EdgeInsets.all(12),
                    color: isActive 
                        ? TacticalTheme.surfaceDark.withOpacity(0.8)
                        : isResponding
                            ? TacticalTheme.neonAmber.withOpacity(0.1)
                            : TacticalTheme.surfaceDark.withOpacity(0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                rescuer['name']!,
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isActive 
                                      ? TacticalTheme.neonGreen
                                      : isResponding
                                          ? TacticalTheme.neonAmber
                                          : TacticalTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActive 
                                    ? TacticalTheme.neonGreen
                                    : isResponding
                                        ? TacticalTheme.neonAmber
                                        : TacticalTheme.surfaceGlass,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                rescuer['status']!,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 8,
                                  color: TacticalTheme.voidBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: TacticalTheme.textSecondary,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rescuer['distance']!,
                              style: GoogleFonts.rajdhani(
                                fontSize: 10,
                                color: TacticalTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
