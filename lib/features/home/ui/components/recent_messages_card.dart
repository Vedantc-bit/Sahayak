import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/tactical_theme.dart';

class RecentMessagesCard extends StatelessWidget {
  const RecentMessagesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {
        'id': 'MSG-001',
        'type': 'SOS',
        'content': 'Need immediate medical assistance at coordinates 37.7749, -122.4194',
        'time': '14:32:18',
        'sender': 'MED-UNIT-1',
        'priority': 0,
      },
      {
        'id': 'MSG-002',
        'type': 'MEDICAL',
        'content': 'Patient stable, awaiting evacuation',
        'time': '14:28:45',
        'sender': 'FIRE-TEAM-3',
        'priority': 1,
      },
      {
        'id': 'MSG-003',
        'type': 'ALERT',
        'content': 'Severe weather warning - seek shelter immediately',
        'time': '14:45:12',
        'sender': 'CMD-CENTER',
        'priority': 2,
      },
      {
        'id': 'MSG-004',
        'type': 'CHAT',
        'content': 'Network status update - all systems operational',
        'time': '14:52:33',
        'sender': 'TECH-UNIT-5',
        'priority': 3,
      },
    ];

    return TacticalTheme.glassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: TacticalTheme.neonCyan,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'DATA LOGS',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TacticalTheme.neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final priorityColor = TacticalTheme.getPriorityColor(message['priority'] as int);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: TacticalTheme.chamferedContainer(
                    chamferSize: 4,
                    padding: const EdgeInsets.all(12),
                    color: TacticalTheme.surfaceDark.withOpacity(0.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                message['type'] as String,
                                style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  color: priorityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              message['time']?.toString() ?? '',
                              style: GoogleFonts.rajdhani(
                                fontSize: 10,
                                color: TacticalTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message['content'] as String,
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            color: TacticalTheme.textPrimary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              message['time'] as String,
                              style: GoogleFonts.rajdhani(
                                fontSize: 10,
                                color: TacticalTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              message['sender']?.toString() ?? '',
                              style: GoogleFonts.rajdhani(
                                fontSize: 10,
                                color: TacticalTheme.neonCyan,
                                fontWeight: FontWeight.bold,
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
