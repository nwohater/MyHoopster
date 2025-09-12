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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.game_controller_solid,
            size: 80,
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
          const SizedBox(height: 20),
          const Text(
            'No opponent selected',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Go to Parks to challenge an opponent',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 30),
          CupertinoButton.filled(
            child: const Text('Go to Parks'),
            onPressed: () {
              TabNavigator.of(context)?.tabController.index = 3;
            },
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
        Column(
          children: [
            _buildScoreboard(context, player, opponent),
            Expanded(
              child: _buildCourt(context, gameProvider),
            ),
            if (isMatchInProgress && isPlayerTurn && !isMatchComplete)
              _buildActionButtons(context, gameProvider),
            if (isMatchComplete)
              _buildMatchResult(context, gameProvider),
          ],
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
      child: Row(
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
    );
  }
  
  Widget _buildPlayerScore({
    required String name,
    required int score,
    required int ovr,
    required bool isActive,
    required bool isPlayer,
  }) {
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
  
  Widget _buildMatchResult(BuildContext context, GameProvider gameProvider) {
    final won = playerScore >= winningScore;
    final opponent = widget.opponent!;
    
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
    });
  }
  
  void _performAction(GameProvider gameProvider, String action) {
    if (!isMatchInProgress || !isPlayerTurn) return;
    
    final player = gameProvider.player!;
    final opponent = widget.opponent!;
    final random = math.Random();
    
    double successChance = 0.5;
    
    switch (action) {
      case 'shoot':
        successChance = player.attributes.shooting / 150.0;
        break;
      case 'drive':
        successChance = ((player.attributes.speed + player.attributes.dribbling) / 2) / 150.0;
        break;
      case 'trick':
        successChance = player.attributes.dribbling / 150.0;
        break;
    }
    
    final defenseModifier = 1 - (opponent.defense / 200.0);
    successChance *= defenseModifier;
    
    final scored = random.nextDouble() < successChance;
    
    setState(() {
      if (scored) {
        playerScore += action == 'shoot' && random.nextDouble() < 0.3 ? 3 : 2;
        lastAction = action == 'shoot' ? 'Swish!' : action == 'drive' ? 'And one!' : 'Ankle breaker!';
      } else {
        lastAction = 'Missed!';
      }
      
      isPlayerTurn = false;
    });
    
    _animationController.forward(from: 0.0);
    
    if (playerScore >= winningScore) {
      _endMatch(gameProvider, true);
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        _opponentTurn(gameProvider);
      });
    }
  }
  
  void _opponentTurn(GameProvider gameProvider) {
    if (!isMatchInProgress || isPlayerTurn) return;
    
    final player = gameProvider.player!;
    final opponent = widget.opponent!;
    final random = math.Random();
    
    final actions = ['shoot', 'drive', 'trick'];
    final action = actions[random.nextInt(actions.length)];
    
    double successChance = 0.5;
    
    switch (action) {
      case 'shoot':
        successChance = opponent.shooting / 150.0;
        break;
      case 'drive':
        successChance = ((opponent.speed + opponent.dribbling) / 2) / 150.0;
        break;
      case 'trick':
        successChance = opponent.dribbling / 150.0;
        break;
    }
    
    final defenseModifier = 1 - (player.attributes.defense / 200.0);
    successChance *= defenseModifier;
    
    final scored = random.nextDouble() < successChance;
    
    setState(() {
      if (scored) {
        opponentScore += action == 'shoot' && random.nextDouble() < 0.3 ? 3 : 2;
        lastAction = '${opponent.name.split(' ')[0]} scores!';
      } else {
        lastAction = '${opponent.name.split(' ')[0]} misses!';
      }
      
      isPlayerTurn = true;
    });
    
    _animationController.forward(from: 0.0);
    
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