import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import 'dart:math' as math;

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Training'),
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
            
            return _buildTrainingOptions(context, gameProvider);
          },
        ),
      ),
    );
  }
  
  Widget _buildTrainingOptions(BuildContext context, GameProvider gameProvider) {
    final player = gameProvider.player!;
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnergyHeader(context, player),
                const SizedBox(height: 30),
                const Text(
                  'Training Drills',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTrainingCard(
                  context,
                  gameProvider,
                  title: 'Shooting Practice',
                  description: 'Improve your shooting accuracy',
                  icon: CupertinoIcons.scope,
                  color: CupertinoColors.systemRed,
                  attribute: 'shooting',
                  energyCost: 20,
                ),
                const SizedBox(height: 15),
                _buildTrainingCard(
                  context,
                  gameProvider,
                  title: 'Dribbling Drills',
                  description: 'Master your ball handling',
                  icon: CupertinoIcons.sportscourt,
                  color: CupertinoColors.systemGreen,
                  attribute: 'dribbling',
                  energyCost: 20,
                ),
                const SizedBox(height: 15),
                _buildTrainingCard(
                  context,
                  gameProvider,
                  title: 'Speed Training',
                  description: 'Increase your court speed',
                  icon: CupertinoIcons.bolt_fill,
                  color: CupertinoColors.systemBlue,
                  attribute: 'speed',
                  energyCost: 25,
                ),
                const SizedBox(height: 15),
                _buildTrainingCard(
                  context,
                  gameProvider,
                  title: 'Defensive Stance',
                  description: 'Strengthen your defense',
                  icon: CupertinoIcons.shield_fill,
                  color: CupertinoColors.systemPurple,
                  attribute: 'defense',
                  energyCost: 20,
                ),
                const SizedBox(height: 15),
                _buildTrainingCard(
                  context,
                  gameProvider,
                  title: 'Cardio Workout',
                  description: 'Build your stamina',
                  icon: CupertinoIcons.heart_fill,
                  color: CupertinoColors.systemOrange,
                  attribute: 'stamina',
                  energyCost: 30,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEnergyHeader(BuildContext context, player) {
    final energyPercentage = player.energy / player.maxEnergy;
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.bolt_fill,
                    size: 20,
                    color: CupertinoColors.activeGreen.resolveFrom(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Energy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${player.energy}/${player.maxEnergy}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5.resolveFrom(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: energyPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.activeGreen.resolveFrom(context),
                        CupertinoColors.activeGreen.resolveFrom(context).withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrainingCard(
    BuildContext context,
    GameProvider gameProvider, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String attribute,
    required int energyCost,
  }) {
    final player = gameProvider.player!;
    final canTrain = player.energy >= energyCost;
    
    return GestureDetector(
      onTap: canTrain
          ? () => _startTraining(context, gameProvider, title, attribute, energyCost)
          : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: canTrain
              ? color.withOpacity(0.1)
              : CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: canTrain
                ? color.withOpacity(0.3)
                : CupertinoColors.systemGrey4.resolveFrom(context),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canTrain
                    ? color.withOpacity(0.2)
                    : CupertinoColors.systemGrey4.resolveFrom(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: canTrain
                    ? color
                    : CupertinoColors.systemGrey3.resolveFrom(context),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: canTrain
                          ? null
                          : CupertinoColors.systemGrey.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: canTrain
                          ? CupertinoColors.systemGrey.resolveFrom(context)
                          : CupertinoColors.systemGrey3.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: canTrain
                    ? color.withOpacity(0.2)
                    : CupertinoColors.systemGrey4.resolveFrom(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.bolt,
                    size: 16,
                    color: canTrain
                        ? color
                        : CupertinoColors.systemGrey3.resolveFrom(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$energyCost',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: canTrain
                          ? color
                          : CupertinoColors.systemGrey3.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _startTraining(
    BuildContext context,
    GameProvider gameProvider,
    String trainingName,
    String attribute,
    int energyCost,
  ) {
    gameProvider.useEnergy(energyCost);
    
    final random = math.Random();
    final baseXP = 30;
    final bonusXP = random.nextInt(21);
    final totalXP = baseXP + bonusXP;
    
    final improvement = random.nextInt(100) > 70;
    
    gameProvider.addExperience(totalXP);
    
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(trainingName),
          content: Column(
            children: [
              const SizedBox(height: 10),
              Icon(
                improvement ? CupertinoIcons.star_fill : CupertinoIcons.checkmark_circle_fill,
                size: 50,
                color: improvement 
                    ? CupertinoColors.activeOrange
                    : CupertinoColors.activeGreen,
              ),
              const SizedBox(height: 15),
              Text(
                improvement
                    ? 'Excellent training session!'
                    : 'Good training session!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '+$totalXP XP earned',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
              ),
              if (improvement) ...[
                const SizedBox(height: 5),
                Text(
                  'Your ${attribute} improved slightly!',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.activeOrange.resolveFrom(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}