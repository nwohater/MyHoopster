import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../models/park.dart';
import 'match_screen.dart';

class ParksScreen extends StatefulWidget {
  const ParksScreen({super.key});

  @override
  State<ParksScreen> createState() => _ParksScreenState();
}

class _ParksScreenState extends State<ParksScreen> {
  Park? selectedPark;
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Parks'),
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
            
            return _buildParksView(context, gameProvider);
          },
        ),
      ),
    );
  }
  
  Widget _buildParksView(BuildContext context, GameProvider gameProvider) {
    final player = gameProvider.player!;
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a Court',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your Rep: ${player.reputation} • Level: ${player.level}',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final park = parks[index];
              final isUnlocked = park.isUnlocked(player.level, player.reputation);
              final isSelected = selectedPark?.id == park.id;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: _buildParkCard(
                  context,
                  gameProvider,
                  park,
                  isUnlocked,
                  isSelected,
                ),
              );
            },
            childCount: parks.length,
          ),
        ),
        if (selectedPark != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Opponents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...selectedPark!.opponents.map((opponent) => Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: _buildOpponentCard(context, gameProvider, opponent),
                  )),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildParkCard(
    BuildContext context,
    GameProvider gameProvider,
    Park park,
    bool isUnlocked,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              setState(() {
                selectedPark = isSelected ? null : park;
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.activeOrange.resolveFrom(context).withOpacity(0.1)
              : isUnlocked
                  ? CupertinoColors.systemGrey6.resolveFrom(context)
                  : CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.activeOrange.resolveFrom(context)
                : isUnlocked
                    ? CupertinoColors.systemGrey4.resolveFrom(context)
                    : CupertinoColors.systemGrey4.resolveFrom(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        park.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? null
                              : CupertinoColors.systemGrey.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        park.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey.resolveFrom(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(park.difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    park.difficulty,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(park.difficulty),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (!isUnlocked) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.lock_fill,
                      size: 16,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Requires: Level ${park.requiredLevel}, ${park.requiredReputation} Rep',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  _buildParkStat(
                    icon: CupertinoIcons.person_2_fill,
                    value: '${park.opponents.length}',
                    label: 'Opponents',
                  ),
                  const SizedBox(width: 20),
                  _buildParkStat(
                    icon: CupertinoIcons.star_fill,
                    value: '${park.requiredLevel}+',
                    label: 'Level',
                  ),
                  const SizedBox(width: 20),
                  _buildParkStat(
                    icon: CupertinoIcons.flag_fill,
                    value: '${park.requiredReputation}+',
                    label: 'Rep',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildParkStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildOpponentCard(BuildContext context, GameProvider gameProvider, Opponent opponent) {
    final player = gameProvider.player!;
    final canChallenge = player.canPlayMatch();
    
    return GestureDetector(
      onTap: canChallenge
          ? () => _challengeOpponent(context, gameProvider, opponent)
          : null,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canChallenge
                ? CupertinoColors.activeOrange.resolveFrom(context).withOpacity(0.3)
                : CupertinoColors.systemGrey4.resolveFrom(context),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opponent.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      opponent.playstyle,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeOrange.resolveFrom(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'OVR ${opponent.overallRating}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeOrange.resolveFrom(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOpponentStat('SPD', opponent.speed),
                _buildOpponentStat('SHT', opponent.shooting),
                _buildOpponentStat('DRB', opponent.dribbling),
                _buildOpponentStat('DEF', opponent.defense),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildReward(
                    icon: CupertinoIcons.money_dollar_circle,
                    value: '+${opponent.rewardCoins}',
                    color: CupertinoColors.activeGreen,
                  ),
                  _buildReward(
                    icon: CupertinoIcons.star_circle,
                    value: '+${opponent.rewardXP} XP',
                    color: CupertinoColors.activeBlue,
                  ),
                  _buildReward(
                    icon: CupertinoIcons.flag_fill,
                    value: '+${opponent.rewardReputation}',
                    color: CupertinoColors.activeOrange,
                  ),
                ],
              ),
            ),
            if (canChallenge) ...[
              const SizedBox(height: 15),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeOrange.resolveFrom(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Challenge (30 Energy)',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onPressed: () => _challengeOpponent(context, gameProvider, opponent),
              ),
            ] else ...[
              const SizedBox(height: 15),
              Text(
                'Not enough energy (30 required)',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildOpponentStat(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildReward({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return CupertinoColors.activeGreen;
      case 'Medium':
        return CupertinoColors.activeOrange;
      case 'Hard':
        return CupertinoColors.systemRed;
      case 'Legendary':
        return CupertinoColors.systemPurple;
      default:
        return CupertinoColors.systemGrey;
    }
  }
  
  void _challengeOpponent(BuildContext context, GameProvider gameProvider, Opponent opponent) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => MatchScreen(opponent: opponent),
      ),
    );
  }
}