import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../widgets/skill_meter.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Player Profile'),
      ),
      child: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            if (gameProvider.isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            
            if (!gameProvider.hasPlayer) {
              return const Center(
                child: Text(
                  'Create a player from the Home screen',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            
            return _buildPlayerProfile(context, gameProvider);
          },
        ),
      ),
    );
  }
  
  Widget _buildPlayerProfile(BuildContext context, GameProvider gameProvider) {
    final player = gameProvider.player!;
    final attributes = player.attributes;
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, player),
                const SizedBox(height: 30),
                _buildAttributesSection(context, gameProvider, attributes),
                const SizedBox(height: 30),
                _buildPhysicalSection(context, attributes),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfileHeader(BuildContext context, player) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CupertinoColors.activeOrange.resolveFrom(context),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              size: 40,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Level ${player.level} • OVR ${player.overallRating}',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      size: 16,
                      color: CupertinoColors.activeOrange.resolveFrom(context),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${player.skillPoints} Skill Points',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.activeOrange.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttributesSection(BuildContext context, GameProvider gameProvider, attributes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attributes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (gameProvider.player!.skillPoints > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeOrange.resolveFrom(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${gameProvider.player!.skillPoints} points available',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.activeOrange.resolveFrom(context),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        SkillMeter(
          label: 'Speed',
          value: attributes.speed,
          maxValue: 99,
          icon: CupertinoIcons.bolt_fill,
          color: CupertinoColors.systemBlue,
          onUpgrade: gameProvider.player!.skillPoints > 0
              ? () => _showUpgradeDialog(context, gameProvider, 'speed', attributes.speed)
              : null,
        ),
        const SizedBox(height: 15),
        SkillMeter(
          label: 'Shooting',
          value: attributes.shooting,
          maxValue: 99,
          icon: CupertinoIcons.scope,
          color: CupertinoColors.systemRed,
          onUpgrade: gameProvider.player!.skillPoints > 0
              ? () => _showUpgradeDialog(context, gameProvider, 'shooting', attributes.shooting)
              : null,
        ),
        const SizedBox(height: 15),
        SkillMeter(
          label: 'Dribbling',
          value: attributes.dribbling,
          maxValue: 99,
          icon: CupertinoIcons.sportscourt,
          color: CupertinoColors.systemGreen,
          onUpgrade: gameProvider.player!.skillPoints > 0
              ? () => _showUpgradeDialog(context, gameProvider, 'dribbling', attributes.dribbling)
              : null,
        ),
        const SizedBox(height: 15),
        SkillMeter(
          label: 'Defense',
          value: attributes.defense,
          maxValue: 99,
          icon: CupertinoIcons.shield_fill,
          color: CupertinoColors.systemPurple,
          onUpgrade: gameProvider.player!.skillPoints > 0
              ? () => _showUpgradeDialog(context, gameProvider, 'defense', attributes.defense)
              : null,
        ),
        const SizedBox(height: 15),
        SkillMeter(
          label: 'Stamina',
          value: attributes.stamina,
          maxValue: 99,
          icon: CupertinoIcons.heart_fill,
          color: CupertinoColors.systemOrange,
          onUpgrade: gameProvider.player!.skillPoints > 0
              ? () => _showUpgradeDialog(context, gameProvider, 'stamina', attributes.stamina)
              : null,
        ),
      ],
    );
  }
  
  Widget _buildPhysicalSection(BuildContext context, attributes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Physical',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.arrow_up_down,
                    size: 24,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Height',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${attributes.height} cm',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showUpgradeDialog(BuildContext context, GameProvider gameProvider, String attribute, int currentValue) {
    int pointsToSpend = 1;
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final maxPoints = gameProvider.player!.skillPoints.clamp(0, 99 - currentValue);
            
            return CupertinoActionSheet(
              title: Text('Upgrade ${attribute.substring(0, 1).toUpperCase()}${attribute.substring(1)}'),
              message: Column(
                children: [
                  const SizedBox(height: 10),
                  Text('Current: $currentValue → ${currentValue + pointsToSpend}'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.minus_circle_fill),
                        onPressed: pointsToSpend > 1
                            ? () => setState(() => pointsToSpend--)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pointsToSpend',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.plus_circle_fill),
                        onPressed: pointsToSpend < maxPoints
                            ? () => setState(() => pointsToSpend++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Skill Points: ${gameProvider.player!.skillPoints} available',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    gameProvider.upgradeAttribute(attribute, pointsToSpend);
                    Navigator.pop(context);
                  },
                  child: Text('Upgrade (+$pointsToSpend)'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            );
          },
        );
      },
    );
  }
}