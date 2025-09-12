import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../services/tab_navigator.dart';
import '../widgets/player_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('My Hoopster'),
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
              return _buildWelcomeScreen(context, gameProvider);
            }
            
            return _buildPlayerOverview(context, gameProvider);
          },
        ),
      ),
    );
  }
  
  Widget _buildWelcomeScreen(BuildContext context, GameProvider gameProvider) {
    final nameController = TextEditingController();
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.sportscourt_fill,
            size: 100,
            color: CupertinoColors.activeOrange.resolveFrom(context),
          ),
          const SizedBox(height: 30),
          const Text(
            'Welcome to My Hoopster!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create your player to begin your journey',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          CupertinoTextField(
            controller: nameController,
            placeholder: 'Enter your player name',
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.resolveFrom(context),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          CupertinoButton.filled(
            child: const Text('Create Player'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                gameProvider.createPlayer(nameController.text);
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayerOverview(BuildContext context, GameProvider gameProvider) {
    final player = gameProvider.player!;
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayerCard(player: player),
                const SizedBox(height: 30),
                _buildQuickActions(context, gameProvider),
                const SizedBox(height: 30),
                _buildEnergySection(context, gameProvider),
                const SizedBox(height: 30),
                _buildStatsSection(context, gameProvider),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions(BuildContext context, GameProvider gameProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: CupertinoIcons.sportscourt,
                label: 'Train',
                color: CupertinoColors.activeGreen,
                enabled: gameProvider.player!.canTrain(),
                onTap: () {
                  TabNavigator.of(context)?.tabController.index = 2;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                context,
                icon: CupertinoIcons.game_controller_solid,
                label: 'Match',
                color: CupertinoColors.activeOrange,
                enabled: gameProvider.player!.canPlayMatch(),
                onTap: () {
                  TabNavigator.of(context)?.tabController.index = 4;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: enabled 
              ? color.withOpacity(0.1)
              : CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: enabled 
                ? color.withOpacity(0.3)
                : CupertinoColors.systemGrey4.resolveFrom(context),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: enabled 
                  ? color
                  : CupertinoColors.systemGrey3.resolveFrom(context),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: enabled 
                    ? color
                    : CupertinoColors.systemGrey3.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEnergySection(BuildContext context, GameProvider gameProvider) {
    final player = gameProvider.player!;
    final energyPercentage = player.energy / player.maxEnergy;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Energy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${player.energy}/${player.maxEnergy}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 30,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5.resolveFrom(context),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: energyPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.activeGreen.resolveFrom(context),
                          CupertinoColors.activeGreen.resolveFrom(context).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            'Restore Energy (50 coins)',
            style: TextStyle(
              color: player.coins >= 50 
                  ? CupertinoColors.activeBlue 
                  : CupertinoColors.systemGrey3,
            ),
          ),
          onPressed: player.coins >= 50 
              ? () {
                  if (gameProvider.spendCoins(50)) {
                    gameProvider.restoreFullEnergy();
                  }
                }
              : null,
        ),
      ],
    );
  }
  
  Widget _buildStatsSection(BuildContext context, GameProvider gameProvider) {
    final stats = gameProvider.player!.stats;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Career Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              _buildStatRow('Matches', stats.matchesPlayed.toString()),
              const SizedBox(height: 10),
              _buildStatRow('Wins', stats.wins.toString()),
              const SizedBox(height: 10),
              _buildStatRow('Win Rate', '${(stats.winRate * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 10),
              _buildStatRow('PPG', stats.pointsPerGame.toStringAsFixed(1)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}