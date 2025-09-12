import 'package:flutter/cupertino.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  
  const PlayerCard({
    super.key,
    required this.player,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.activeOrange.resolveFrom(context),
            CupertinoColors.activeOrange.resolveFrom(context).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.activeOrange.resolveFrom(context).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Level ${player.level}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'OVR ${player.overallRating}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar(
            context,
            label: 'Experience',
            value: player.experienceProgress,
            displayText: '${player.experience}/${player.experienceForNextLevel}',
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: CupertinoIcons.star_fill,
                value: player.skillPoints.toString(),
                label: 'Skill Points',
              ),
              _buildStatItem(
                icon: CupertinoIcons.money_dollar_circle_fill,
                value: player.coins.toString(),
                label: 'Coins',
              ),
              _buildStatItem(
                icon: CupertinoIcons.flag_fill,
                value: player.reputation.toString(),
                label: 'Rep',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressBar(
    BuildContext context, {
    required String label,
    required double value,
    required String displayText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: CupertinoColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: CupertinoColors.white,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}