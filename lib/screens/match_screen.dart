import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../services/tab_navigator.dart';
import '../models/park.dart';
import 'dart:math' as math;

class MatchScreen extends StatefulWidget {
  final Opponent? opponent;
  
  const MatchScreen({super.key, this.opponent});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int playerScore = 0;
  int opponentScore = 0;
  bool isPlayerTurn = true;
  bool isMatchInProgress = false;
  bool isMatchComplete = false;
  String lastAction = '';
  final int winningScore = 21;

  // Stamina system
  double playerStamina = 100.0;
  double opponentStamina = 100.0;
  final double maxStamina = 100.0;

  // Defensive actions
  bool isDefending = false;
  String? defensiveAction; // 'steal' or 'block'

  // Momentum/Streak system
  int playerStreak = 0; // Positive = hot streak, Negative = cold streak
  int opponentStreak = 0;
  static const int hotStreakThreshold = 3; // 3+ makes = hot
  static const int coldStreakThreshold = -3; // 3+ misses = cold

  // Match Statistics
  final Map<String, int> playerStats = {
    'fgMade': 0,
    'fgAttempted': 0,
    'threeMade': 0,
    'threeAttempted': 0,
    'turnovers': 0,
    'steals': 0,
    'blocks': 0,
  };

  final Map<String, int> opponentStats = {
    'fgMade': 0,
    'fgAttempted': 0,
    'threeMade': 0,
    'threeAttempted': 0,
    'turnovers': 0,
    'steals': 0,
    'blocks': 0,
  };

  bool showStats = false; // Toggle for stats view
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    if (widget.opponent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startMatch();
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('1v1 Match'),
        leading: widget.opponent != null && isMatchInProgress
            ? Container()
            : null,
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
            
            if (widget.opponent == null) {
              return _buildNoOpponentView(context);
            }
            
            return _buildMatchView(context, gameProvider);
          },
        ),
      ),
    );
  }
  
  Widget _buildNoOpponentView(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final player = gameProvider.player;

    if (player == null) {
      return const Center(
        child: Text(
          'Create a player from the Home screen',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Match History',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your career statistics',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 30),

                // Overall Record
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.activeOrange.resolveFrom(context).withOpacity(0.2),
                        CupertinoColors.activeOrange.resolveFrom(context).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: CupertinoColors.activeOrange.resolveFrom(context).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRecordStat(
                        label: 'Wins',
                        value: '${player.stats.wins}',
                        color: CupertinoColors.activeGreen,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: CupertinoColors.systemGrey4.resolveFrom(context),
                      ),
                      _buildRecordStat(
                        label: 'Losses',
                        value: '${player.stats.losses}',
                        color: CupertinoColors.systemRed,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: CupertinoColors.systemGrey4.resolveFrom(context),
                      ),
                      _buildRecordStat(
                        label: 'Win %',
                        value: player.stats.matchesPlayed > 0
                            ? '${(player.stats.winRate * 100).toStringAsFixed(0)}%'
                            : '0%',
                        color: CupertinoColors.activeOrange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Stats Grid
                _buildStatCard(
                  context,
                  icon: CupertinoIcons.game_controller_solid,
                  label: 'Matches Played',
                  value: '${player.stats.matchesPlayed}',
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(height: 15),
                _buildStatCard(
                  context,
                  icon: CupertinoIcons.sportscourt,
                  label: 'Total Points',
                  value: '${player.stats.totalPoints}',
                  color: CupertinoColors.systemPurple,
                ),
                const SizedBox(height: 15),
                _buildStatCard(
                  context,
                  icon: CupertinoIcons.chart_bar_fill,
                  label: 'Points Per Game',
                  value: player.stats.matchesPlayed > 0
                      ? player.stats.pointsPerGame.toStringAsFixed(1)
                      : '0.0',
                  color: CupertinoColors.systemIndigo,
                ),

                const SizedBox(height: 30),

                // Call to Action
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeOrange.resolveFrom(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.location_fill,
                            color: CupertinoColors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Find Opponent',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onPressed: () {
                    TabNavigator.of(context)?.tabController.index = 3;
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMatchView(BuildContext context, GameProvider gameProvider) {
    final player = gameProvider.player!;
    final opponent = widget.opponent!;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              _buildScoreboard(context, player, opponent),
              SizedBox(
                height: 300,
                child: _buildCourt(context, gameProvider),
              ),
              if (isMatchInProgress && isPlayerTurn && !isMatchComplete)
                _buildActionButtons(context, gameProvider),
              if (isMatchInProgress && !isPlayerTurn && !isMatchComplete && !isDefending)
                _buildDefensiveButtons(context, gameProvider),
              if (isMatchComplete)
                _buildMatchResult(context, gameProvider),
            ],
          ),
        ),
        if (lastAction.isNotEmpty)
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: 1.0 - _animationController.value,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: CupertinoColors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lastAction,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ),
      ],
    );
  }
  
  Widget _buildScoreboard(BuildContext context, player, Opponent opponent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPlayerScore(
                name: player.name,
                score: playerScore,
                ovr: player.overallRating,
                isActive: isPlayerTurn,
                isPlayer: true,
              ),
              Column(
                children: [
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'First to $winningScore',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              _buildPlayerScore(
                name: opponent.name.split(' ')[0],
                score: opponentScore,
                ovr: opponent.overallRating,
                isActive: !isPlayerTurn,
                isPlayer: false,
              ),
            ],
          ),
          const SizedBox(height: 15),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minSize: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  showStats ? CupertinoIcons.chart_bar_fill : CupertinoIcons.chart_bar,
                  size: 16,
                  color: CupertinoColors.activeOrange,
                ),
                const SizedBox(width: 6),
                Text(
                  showStats ? 'Hide Stats' : 'Show Stats',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.activeOrange,
                  ),
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                showStats = !showStats;
              });
            },
          ),
          if (showStats) ...[
            const SizedBox(height: 15),
            _buildStatsDisplay(context),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPlayerScore({
    required String name,
    required int score,
    required int ovr,
    required bool isActive,
    required bool isPlayer,
  }) {
    final currentStamina = isPlayer ? playerStamina : opponentStamina;
    final staminaPercent = currentStamina / maxStamina;
    final currentStreak = isPlayer ? playerStreak : opponentStreak;
    final streakStatus = _getStreakStatus(currentStreak);
    final streakColor = _getStreakColor(currentStreak);

    // Color based on stamina level
    Color staminaColor;
    if (staminaPercent > 0.6) {
      staminaColor = CupertinoColors.activeGreen;
    } else if (staminaPercent > 0.3) {
      staminaColor = CupertinoColors.systemYellow;
    } else {
      staminaColor = CupertinoColors.systemRed;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? CupertinoColors.activeOrange.withOpacity(0.2)
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? CupertinoColors.activeOrange : null,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isActive ? CupertinoColors.activeOrange : null,
                ),
              ),
              Text(
                'OVR $ovr',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 8),
              // Stamina bar
              Container(
                width: 80,
                height: 6,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: staminaPercent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: staminaColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${currentStamina.toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: staminaColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Streak indicator
              if (streakStatus.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: streakColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: streakColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    streakStatus,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: streakColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCourt(BuildContext context, GameProvider gameProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CupertinoColors.systemOrange.resolveFrom(context).withOpacity(0.3),
            CupertinoColors.systemOrange.resolveFrom(context).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CupertinoColors.systemOrange.resolveFrom(context),
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CupertinoColors.systemOrange.resolveFrom(context).withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              height: double.infinity,
              width: 2,
              color: CupertinoColors.systemOrange.resolveFrom(context).withOpacity(0.3),
            ),
          ),
          if (!isMatchInProgress && !isMatchComplete)
            Center(
              child: CupertinoButton.filled(
                child: const Text('Start Match'),
                onPressed: () => _startMatch(),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Your Turn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                label: 'Shoot',
                icon: CupertinoIcons.scope,
                color: CupertinoColors.systemRed,
                onTap: () => _performAction(gameProvider, 'shoot'),
              ),
              _buildActionButton(
                context,
                label: 'Drive',
                icon: CupertinoIcons.arrow_right_circle_fill,
                color: CupertinoColors.systemGreen,
                onTap: () => _performAction(gameProvider, 'drive'),
              ),
              _buildActionButton(
                context,
                label: 'Trick',
                icon: CupertinoIcons.star_fill,
                color: CupertinoColors.systemPurple,
                onTap: () => _performAction(gameProvider, 'trick'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefensiveButtons(BuildContext context, GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Opponent\'s Turn - Play Defense!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                label: 'Steal',
                icon: CupertinoIcons.hand_raised_fill,
                color: CupertinoColors.systemBlue,
                onTap: () => _attemptDefense(gameProvider, 'steal'),
              ),
              _buildActionButton(
                context,
                label: 'Block',
                icon: CupertinoIcons.shield_fill,
                color: CupertinoColors.systemIndigo,
                onTap: () => _attemptDefense(gameProvider, 'block'),
              ),
              _buildActionButton(
                context,
                label: 'Let Play',
                icon: CupertinoIcons.arrow_right,
                color: CupertinoColors.systemGrey,
                onTap: () {
                  setState(() {
                    isDefending = true;
                    defensiveAction = null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMatchResult(BuildContext context, GameProvider gameProvider) {
    final won = playerScore >= winningScore;
    final opponent = widget.opponent!;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6.resolveFrom(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? CupertinoIcons.flag_fill : CupertinoIcons.xmark_circle_fill,
              size: 50,
              color: won ? CupertinoColors.activeOrange : CupertinoColors.systemRed,
            ),
            const SizedBox(height: 10),
            Text(
              won ? 'Victory!' : 'Defeat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: won ? CupertinoColors.activeOrange : CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Final Score: $playerScore - $opponentScore',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            if (won) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5.resolveFrom(context),
                  borderRadius: BorderRadius.circular(10),
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
            ],
            const SizedBox(height: 20),
            CupertinoButton.filled(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
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
          size: 20,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
  
  void _startMatch() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.useEnergy(30);

    setState(() {
      isMatchInProgress = true;
      playerScore = 0;
      opponentScore = 0;
      isPlayerTurn = true;
      isMatchComplete = false;
      playerStamina = maxStamina;
      opponentStamina = maxStamina;
      isDefending = false;
      defensiveAction = null;
      playerStreak = 0;
      opponentStreak = 0;
      showStats = false;
      _resetStats();
    });
  }
  
  void _performAction(GameProvider gameProvider, String action) {
    if (!isMatchInProgress || !isPlayerTurn) return;

    // Reset defensive state
    setState(() {
      isDefending = false;
      defensiveAction = null;
    });

    final player = gameProvider.player!;
    final opponent = widget.opponent!;
    final random = math.Random();

    // Calculate base success chance with IMPROVED percentages
    // Instead of harsh division by 150, use realistic ranges
    double successChance = 0.5;
    int pointsOnMake = 2;
    double staminaCost = 3.0;

    switch (action) {
      case 'shoot':
        // Mid-range shot: scale shooting (50-99) to 40-65% base
        // Rating 50 → ~45%, Rating 99 → ~75%
        successChance = 0.30 + (player.attributes.shooting / 200.0);
        pointsOnMake = 2;
        staminaCost = 3.0;
        break;
      case 'drive':
        // Layup/Drive: more reliable but not guaranteed
        // Rating 50 → ~45%, Rating 99 → ~70%
        final drivePower = ((player.attributes.speed + player.attributes.dribbling) / 2);
        successChance = 0.35 + (drivePower / 250.0);
        pointsOnMake = 2;
        staminaCost = 5.0; // More tiring due to explosive movement
        break;
      case 'trick':
        // Ankle breaker/stepback: hardest to execute
        // Rating 50 → ~40%, Rating 99 → ~65%
        successChance = 0.25 + (player.attributes.dribbling / 200.0);
        pointsOnMake = 2;
        staminaCost = 4.0;
        break;
    }

    // Apply defense modifier - now MUCH MORE IMPACTFUL & VISIBLE
    // Opponent defense (50-99) reduces success by 5-20%
    final defenseReduction = (opponent.defense - 50) / 500.0; // scales from 0 to ~10%
    final defenseModifier = 1.0 - defenseReduction;
    successChance *= defenseModifier;

    // Apply fatigue modifier based on current stamina
    final fatigueModifier = _getFatigueModifier(playerStamina, player.attributes.stamina);
    successChance *= fatigueModifier;

    // Apply momentum modifier based on current streak
    final momentumModifier = _getMomentumModifier(playerStreak);
    successChance *= momentumModifier;

    // Clamp success chance to 0-100%
    successChance = successChance.clamp(0.0, 1.0);

    // Reduce stamina for this action (now using proper stamina cost)
    playerStamina = (playerStamina - staminaCost).clamp(0.0, maxStamina);

    // Determine if this will be a 3-pointer BEFORE calculating shot outcome
    // Only "shoot" actions can be 3-pointers (30% chance)
    final isThreeAttempt = action == 'shoot' && random.nextDouble() < 0.3;

    final scored = random.nextDouble() < successChance;

    // Update streak
    _updateStreak(true, scored);

    setState(() {
      // Track FG attempts and makes (includes 2pt + 3pt)
      playerStats['fgAttempted'] = (playerStats['fgAttempted'] ?? 0) + 1;
      
      // Track 3-point attempts separately
      if (isThreeAttempt) {
        playerStats['threeAttempted'] = (playerStats['threeAttempted'] ?? 0) + 1;
      }

      if (scored) {
        playerStats['fgMade'] = (playerStats['fgMade'] ?? 0) + 1;

        if (isThreeAttempt) {
          playerStats['threeMade'] = (playerStats['threeMade'] ?? 0) + 1;
          playerScore += 3;
        } else {
          playerScore += 2;
        }

        // Add streak-aware messages
        String baseMessage = isThreeAttempt
            ? 'Three!'
            : action == 'shoot'
                ? 'Swish!'
                : action == 'drive'
                    ? 'And one!'
                    : 'Ankle breaker!';
        if (playerStreak >= hotStreakThreshold) {
          baseMessage = '🔥 $baseMessage HEATING UP!';
        }
        lastAction = baseMessage;
      } else {
        String baseMessage = 'Missed!';
        if (playerStreak <= coldStreakThreshold) {
          baseMessage = '🧊 $baseMessage Can\'t buy a bucket...';
        }
        lastAction = baseMessage;
      }

      isPlayerTurn = false;
    });

    _animationController.forward(from: 0.0);

    if (playerScore >= winningScore) {
      _endMatch(gameProvider, true);
    } else {
      // Small stamina recovery for opponent before their turn
      _recoverStamina(false, opponent.defense); // Using defense as stamina proxy

      Future.delayed(const Duration(seconds: 2), () {
        _opponentTurn(gameProvider);
      });
    }
  }
  
  /// Attempt a defensive action (steal or block)
  void _attemptDefense(GameProvider gameProvider, String action) {
    setState(() {
      isDefending = true;
      defensiveAction = action;
    });
  }

  /// Get momentum modifier based on current streak
  /// Returns a value between 0.85 and 1.15
  double _getMomentumModifier(int streak) {
    if (streak >= hotStreakThreshold) {
      // Hot streak: +10-15% bonus
      final bonus = 0.10 + ((streak - hotStreakThreshold) * 0.01).clamp(0.0, 0.05);
      return 1.0 + bonus;
    } else if (streak <= coldStreakThreshold) {
      // Cold streak: -5-10% penalty
      final penalty = 0.05 + ((coldStreakThreshold - streak).abs() * 0.01).clamp(0.0, 0.05);
      return 1.0 - penalty;
    }
    return 1.0; // No modifier
  }

  /// Update streak based on success/failure
  void _updateStreak(bool isPlayer, bool success) {
    setState(() {
      if (isPlayer) {
        if (success) {
          playerStreak = playerStreak < 0 ? 1 : playerStreak + 1;
        } else {
          playerStreak = playerStreak > 0 ? -1 : playerStreak - 1;
        }
      } else {
        if (success) {
          opponentStreak = opponentStreak < 0 ? 1 : opponentStreak + 1;
        } else {
          opponentStreak = opponentStreak > 0 ? -1 : opponentStreak - 1;
        }
      }
    });
  }

  /// Get streak status text
  String _getStreakStatus(int streak) {
    if (streak >= hotStreakThreshold) {
      return '🔥 ON FIRE!';
    } else if (streak <= coldStreakThreshold) {
      return '🧊 COLD';
    }
    return '';
  }

  /// Get streak color
  Color _getStreakColor(int streak) {
    if (streak >= hotStreakThreshold) {
      return CupertinoColors.systemOrange;
    } else if (streak <= coldStreakThreshold) {
      return CupertinoColors.systemBlue;
    }
    return CupertinoColors.systemGrey;
  }

  /// Calculate field goal percentage
  double _getFGPercentage(Map<String, int> stats) {
    final attempted = stats['fgAttempted'] ?? 0;
    if (attempted == 0) return 0.0;
    final made = stats['fgMade'] ?? 0;
    return (made / attempted) * 100;
  }

  /// Calculate three-point percentage
  double _getThreePercentage(Map<String, int> stats) {
    final attempted = stats['threeAttempted'] ?? 0;
    if (attempted == 0) return 0.0;
    final made = stats['threeMade'] ?? 0;
    return (made / attempted) * 100;
  }

  /// Reset all match statistics
  void _resetStats() {
    playerStats.forEach((key, value) {
      playerStats[key] = 0;
    });
    opponentStats.forEach((key, value) {
      opponentStats[key] = 0;
    });
  }

  /// Build stats display widget
  Widget _buildStatsDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildStatRow(
            context,
            label: 'FG%',
            playerValue: '${_getFGPercentage(playerStats).toStringAsFixed(1)}%',
            opponentValue: '${_getFGPercentage(opponentStats).toStringAsFixed(1)}%',
            playerRaw: '${playerStats['fgMade']}/${playerStats['fgAttempted']}',
            opponentRaw: '${opponentStats['fgMade']}/${opponentStats['fgAttempted']}',
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: CupertinoColors.systemGrey5.resolveFrom(context),
          ),
          _buildStatRow(
            context,
            label: '3P%',
            playerValue: '${_getThreePercentage(playerStats).toStringAsFixed(1)}%',
            opponentValue: '${_getThreePercentage(opponentStats).toStringAsFixed(1)}%',
            playerRaw: '${playerStats['threeMade']}/${playerStats['threeAttempted']}',
            opponentRaw: '${opponentStats['threeMade']}/${opponentStats['threeAttempted']}',
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: CupertinoColors.systemGrey5.resolveFrom(context),
          ),
          _buildStatRow(
            context,
            label: 'Steals',
            playerValue: '${playerStats['steals']}',
            opponentValue: '${opponentStats['steals']}',
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: CupertinoColors.systemGrey5.resolveFrom(context),
          ),
          _buildStatRow(
            context,
            label: 'Blocks',
            playerValue: '${playerStats['blocks']}',
            opponentValue: '${opponentStats['blocks']}',
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: CupertinoColors.systemGrey5.resolveFrom(context),
          ),
          _buildStatRow(
            context,
            label: 'Turnovers',
            playerValue: '${playerStats['turnovers']}',
            opponentValue: '${opponentStats['turnovers']}',
          ),
        ],
      ),
    );
  }

  /// Build individual stat row
  Widget _buildStatRow(
    BuildContext context, {
    required String label,
    required String playerValue,
    required String opponentValue,
    String? playerRaw,
    String? opponentRaw,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                playerValue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeOrange,
                ),
              ),
              if (playerRaw != null)
                Text(
                  playerRaw,
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opponentValue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              if (opponentRaw != null)
                Text(
                  opponentRaw,
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get stamina cost for an action
  double _getStaminaCost(String action) {
    switch (action) {
      case 'shoot':
        return 3.0; // Least tiring
      case 'drive':
        return 6.0; // Most tiring - explosive movement
      case 'trick':
        return 5.0; // Moderately tiring - quick movements
      default:
        return 4.0;
    }
  }

  /// Calculate fatigue modifier based on current stamina and stamina attribute
  /// Returns a value between 0.5 and 1.0
  double _getFatigueModifier(double currentStamina, int staminaAttribute) {
    // Stamina percentage (0.0 to 1.0)
    final staminaPercent = currentStamina / maxStamina;

    // Higher stamina attribute = better performance when tired
    // Stamina attribute ranges from 50-99
    final staminaFactor = staminaAttribute / 100.0;

    // Base modifier from current stamina (0.5 to 1.0)
    final baseModifier = 0.5 + (staminaPercent * 0.5);

    // Stamina attribute reduces the penalty when tired
    // If stamina is high (90+), penalty is minimal even when tired
    // If stamina is low (50), penalty is more severe
    final adjustedModifier = baseModifier + ((1.0 - baseModifier) * staminaFactor * 0.5);

    return adjustedModifier.clamp(0.5, 1.0);
  }

  /// Reduce stamina and apply small recovery
  void _updateStamina(bool isPlayer, String action) {
    final cost = _getStaminaCost(action);

    setState(() {
      if (isPlayer) {
        playerStamina = (playerStamina - cost).clamp(0.0, maxStamina);
      } else {
        opponentStamina = (opponentStamina - cost).clamp(0.0, maxStamina);
      }
    });
  }

  /// Small stamina recovery between possessions
  void _recoverStamina(bool isPlayer, int staminaAttribute) {
    // Recovery amount based on stamina attribute (1-3 points)
    final recovery = 1.0 + (staminaAttribute / 50.0);

    setState(() {
      if (isPlayer) {
        playerStamina = (playerStamina + recovery).clamp(0.0, maxStamina);
      } else {
        opponentStamina = (opponentStamina + recovery).clamp(0.0, maxStamina);
      }
    });
  }

  /// Get action weights based on opponent's playstyle
  Map<String, double> _getPlaystyleWeights(String playstyle) {
    switch (playstyle.toLowerCase()) {
      case 'shooter':
        return {'shoot': 0.60, 'drive': 0.25, 'trick': 0.15};
      case 'speedster':
      case 'athletic':
        return {'shoot': 0.25, 'drive': 0.60, 'trick': 0.15};
      case 'dribbler':
      case 'streetball':
      case 'flashy':
        return {'shoot': 0.25, 'drive': 0.30, 'trick': 0.45};
      case 'defender':
        return {'shoot': 0.50, 'drive': 0.35, 'trick': 0.15};
      case 'scorer':
        return {'shoot': 0.50, 'drive': 0.35, 'trick': 0.15};
      case 'all-around':
      case 'balanced':
        return {'shoot': 0.35, 'drive': 0.35, 'trick': 0.30};
      case 'legendary':
        return {'shoot': 0.40, 'drive': 0.30, 'trick': 0.30};
      default:
        return {'shoot': 0.33, 'drive': 0.33, 'trick': 0.34};
    }
  }

  /// Select action based on weighted probabilities
  String _selectWeightedAction(Map<String, double> weights) {
    final random = math.Random();
    final roll = random.nextDouble();

    double cumulative = 0.0;
    for (final entry in weights.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) {
        return entry.key;
      }
    }

    return 'shoot'; // Fallback
  }

  void _opponentTurn(GameProvider gameProvider) {
    if (!isMatchInProgress || isPlayerTurn) return;

    final player = gameProvider.player!;
    final opponent = widget.opponent!;
    final random = math.Random();

    // Check if player is attempting a defensive action
    bool defensiveSuccess = false;
    String defenseResult = '';

    if (defensiveAction != null) {
      // Calculate defensive success chance
      double defenseChance = 0.0;

      if (defensiveAction == 'steal') {
        // Steal: player's defense vs opponent's dribbling
        defenseChance = (player.attributes.defense / (player.attributes.defense + opponent.dribbling)) * 0.4; // Max 40% chance
      } else if (defensiveAction == 'block') {
        // Block: player's defense vs opponent's shooting/speed
        final opponentOffense = (opponent.shooting + opponent.speed) / 2;
        defenseChance = (player.attributes.defense / (player.attributes.defense + opponentOffense)) * 0.35; // Max 35% chance
      }

      defensiveSuccess = random.nextDouble() < defenseChance;

      if (defensiveSuccess) {
        // Defensive action succeeded!
        setState(() {
          if (defensiveAction == 'steal') {
            playerStats['steals'] = (playerStats['steals'] ?? 0) + 1;
            opponentStats['turnovers'] = (opponentStats['turnovers'] ?? 0) + 1;
            lastAction = 'STEAL! You got the ball!';
            isPlayerTurn = true;
            isDefending = false;
            defensiveAction = null;
          } else {
            playerStats['blocks'] = (playerStats['blocks'] ?? 0) + 1;
            lastAction = 'BLOCKED! Great defense!';
            isPlayerTurn = true;
            isDefending = false;
            defensiveAction = null;
          }
        });

        _animationController.forward(from: 0.0);

        // Small stamina recovery for player
        _recoverStamina(true, player.attributes.stamina);

        return; // End opponent's turn, player gets possession
      } else {
        // Defensive action failed - opponent gets bonus
        defenseResult = defensiveAction == 'steal' ? 'Steal attempt failed!' : 'Block attempt failed!';
      }
    }

    // Use playstyle-based action selection
    final weights = _getPlaystyleWeights(opponent.playstyle);
    final action = _selectWeightedAction(weights);

    // Calculate base success chance with IMPROVED percentages (matching player logic)
    double successChance = 0.5;

    switch (action) {
      case 'shoot':
        // Mid-range shot: scale shooting (50-99) to 40-65% base
        // Rating 50 → ~45%, Rating 99 → ~75%
        successChance = 0.30 + (opponent.shooting / 200.0);
        break;
      case 'drive':
        // Layup/Drive: more reliable but not guaranteed
        // Rating 50 → ~45%, Rating 99 → ~70%
        final drivePower = ((opponent.speed + opponent.dribbling) / 2);
        successChance = 0.35 + (drivePower / 250.0);
        break;
      case 'trick':
        // Ankle breaker/stepback: hardest to execute
        // Rating 50 → ~40%, Rating 99 → ~65%
        successChance = 0.25 + (opponent.dribbling / 200.0);
        break;
    }

    // Apply defense modifier - now MUCH MORE IMPACTFUL & VISIBLE
    // Player's defense (50-99) reduces opponent success by 5-20%
    final defenseReduction = (player.attributes.defense - 50) / 500.0;
    final defenseModifier = 1.0 - defenseReduction;
    successChance *= defenseModifier;

    // Apply fatigue modifier (using defense as stamina proxy for opponent)
    final fatigueModifier = _getFatigueModifier(opponentStamina, opponent.defense);
    successChance *= fatigueModifier;

    // Apply momentum modifier based on current streak
    final momentumModifier = _getMomentumModifier(opponentStreak);
    successChance *= momentumModifier;

    // If defensive action failed, opponent gets a bonus
    if (defensiveAction != null && !defensiveSuccess) {
      successChance *= 1.2; // 20% bonus for failed defensive attempt
    }

    // Reduce stamina for this action
    _updateStamina(false, action);

    // Determine if this will be a 3-pointer BEFORE calculating shot outcome
    // Only "shoot" actions can be 3-pointers (30% chance)
    final isThreeAttempt = action == 'shoot' && random.nextDouble() < 0.3;

    final scored = random.nextDouble() < successChance;

    // Update streak
    _updateStreak(false, scored);

    setState(() {
      // Track FG attempts and makes (includes 2pt + 3pt)
      opponentStats['fgAttempted'] = (opponentStats['fgAttempted'] ?? 0) + 1;
      
      // Track 3-point attempts separately
      if (isThreeAttempt) {
        opponentStats['threeAttempted'] = (opponentStats['threeAttempted'] ?? 0) + 1;
      }

      if (scored) {
        opponentStats['fgMade'] = (opponentStats['fgMade'] ?? 0) + 1;

        if (isThreeAttempt) {
          opponentStats['threeMade'] = (opponentStats['threeMade'] ?? 0) + 1;
          opponentScore += 3;
        } else {
          opponentScore += 2;
        }

        String baseMessage = defenseResult.isNotEmpty
            ? '$defenseResult ${opponent.name.split(' ')[0]} scores!'
            : '${opponent.name.split(' ')[0]} scores!';

        if (opponentStreak >= hotStreakThreshold) {
          baseMessage = '🔥 $baseMessage They\'re on fire!';
        }
        lastAction = baseMessage;
      } else {
        String baseMessage = defenseResult.isNotEmpty
            ? '$defenseResult ${opponent.name.split(' ')[0]} misses!'
            : '${opponent.name.split(' ')[0]} misses!';

        if (opponentStreak <= coldStreakThreshold) {
          baseMessage = '🧊 $baseMessage They\'re ice cold!';
        }
        lastAction = baseMessage;
      }

      isPlayerTurn = true;
      isDefending = false;
      defensiveAction = null;
    });

    _animationController.forward(from: 0.0);

    // Small stamina recovery for player before their turn
    _recoverStamina(true, player.attributes.stamina);

    if (opponentScore >= winningScore) {
      _endMatch(gameProvider, false);
    }
  }
  
  void _endMatch(GameProvider gameProvider, bool won) {
    setState(() {
      isMatchComplete = true;
      isMatchInProgress = false;
    });
    
    final opponent = widget.opponent!;
    
    if (won) {
      gameProvider.addCoins(opponent.rewardCoins);
      gameProvider.addExperience(opponent.rewardXP);
      gameProvider.player!.reputation += opponent.rewardReputation;
    } else {
      gameProvider.addExperience(20);
    }
    
    gameProvider.recordMatchResult(
      won: won,
      points: playerScore,
    );
  }
}