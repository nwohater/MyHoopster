class Park {
  final String id;
  final String name;
  final String description;
  final int requiredLevel;
  final int requiredReputation;
  final String difficulty;
  final List<Opponent> opponents;
  
  const Park({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredLevel,
    required this.requiredReputation,
    required this.difficulty,
    required this.opponents,
  });
  
  bool isUnlocked(int playerLevel, int playerReputation) {
    return playerLevel >= requiredLevel && playerReputation >= requiredReputation;
  }
}

class Opponent {
  final String name;
  final int overallRating;
  final int speed;
  final int shooting;
  final int dribbling;
  final int defense;
  final String playstyle;
  final int rewardCoins;
  final int rewardXP;
  final int rewardReputation;
  
  const Opponent({
    required this.name,
    required this.overallRating,
    required this.speed,
    required this.shooting,
    required this.dribbling,
    required this.defense,
    required this.playstyle,
    required this.rewardCoins,
    required this.rewardXP,
    required this.rewardReputation,
  });
}

final List<Park> parks = [
  Park(
    id: 'neighborhood',
    name: 'Neighborhood Court',
    description: 'Your local court. Perfect for beginners.',
    requiredLevel: 1,
    requiredReputation: 0,
    difficulty: 'Easy',
    opponents: [
      Opponent(
        name: 'Jake "Rookie" Smith',
        overallRating: 45,
        speed: 40,
        shooting: 45,
        dribbling: 45,
        defense: 40,
        playstyle: 'Balanced',
        rewardCoins: 30,
        rewardXP: 50,
        rewardReputation: 5,
      ),
      Opponent(
        name: 'Mike "Slowmo" Johnson',
        overallRating: 48,
        speed: 35,
        shooting: 55,
        dribbling: 40,
        defense: 45,
        playstyle: 'Shooter',
        rewardCoins: 35,
        rewardXP: 60,
        rewardReputation: 6,
      ),
      Opponent(
        name: 'Tony "Quick" Rodriguez',
        overallRating: 50,
        speed: 60,
        shooting: 40,
        dribbling: 55,
        defense: 35,
        playstyle: 'Speedster',
        rewardCoins: 40,
        rewardXP: 70,
        rewardReputation: 7,
      ),
    ],
  ),
  Park(
    id: 'downtown',
    name: 'Downtown Courts',
    description: 'Where the competition gets serious.',
    requiredLevel: 5,
    requiredReputation: 25,
    difficulty: 'Medium',
    opponents: [
      Opponent(
        name: 'Alex "The Wall" Chen',
        overallRating: 60,
        speed: 55,
        shooting: 50,
        dribbling: 55,
        defense: 70,
        playstyle: 'Defender',
        rewardCoins: 60,
        rewardXP: 100,
        rewardReputation: 10,
      ),
      Opponent(
        name: 'Marcus "Splash" Williams',
        overallRating: 65,
        speed: 60,
        shooting: 75,
        dribbling: 60,
        defense: 50,
        playstyle: 'Shooter',
        rewardCoins: 70,
        rewardXP: 120,
        rewardReputation: 12,
      ),
      Opponent(
        name: 'Dre "Handles" Thompson',
        overallRating: 68,
        speed: 65,
        shooting: 60,
        dribbling: 80,
        defense: 55,
        playstyle: 'Dribbler',
        rewardCoins: 80,
        rewardXP: 140,
        rewardReputation: 15,
      ),
    ],
  ),
  Park(
    id: 'venice',
    name: 'Venice Beach',
    description: 'The legendary outdoor court. Elite players only.',
    requiredLevel: 10,
    requiredReputation: 100,
    difficulty: 'Hard',
    opponents: [
      Opponent(
        name: 'Jordan "Air" Mitchell',
        overallRating: 75,
        speed: 80,
        shooting: 70,
        dribbling: 75,
        defense: 70,
        playstyle: 'Athletic',
        rewardCoins: 100,
        rewardXP: 200,
        rewardReputation: 20,
      ),
      Opponent(
        name: 'Kobe "Mamba" Bryant Jr.',
        overallRating: 80,
        speed: 75,
        shooting: 85,
        dribbling: 80,
        defense: 75,
        playstyle: 'Scorer',
        rewardCoins: 120,
        rewardXP: 250,
        rewardReputation: 25,
      ),
      Opponent(
        name: 'LeBron "King" James III',
        overallRating: 85,
        speed: 85,
        shooting: 80,
        dribbling: 85,
        defense: 85,
        playstyle: 'All-Around',
        rewardCoins: 150,
        rewardXP: 300,
        rewardReputation: 30,
      ),
    ],
  ),
  Park(
    id: 'rucker',
    name: 'Rucker Park',
    description: 'The mecca of streetball. Legends are made here.',
    requiredLevel: 15,
    requiredReputation: 250,
    difficulty: 'Legendary',
    opponents: [
      Opponent(
        name: 'Professor "Anklebreaker" Williams',
        overallRating: 90,
        speed: 90,
        shooting: 85,
        dribbling: 95,
        defense: 80,
        playstyle: 'Streetball',
        rewardCoins: 200,
        rewardXP: 400,
        rewardReputation: 40,
      ),
      Opponent(
        name: 'Skip "To My Lou" Jackson',
        overallRating: 92,
        speed: 95,
        shooting: 88,
        dribbling: 92,
        defense: 85,
        playstyle: 'Flashy',
        rewardCoins: 250,
        rewardXP: 500,
        rewardReputation: 50,
      ),
      Opponent(
        name: 'Hot Sauce "Legend" Robinson',
        overallRating: 95,
        speed: 92,
        shooting: 90,
        dribbling: 98,
        defense: 88,
        playstyle: 'Legendary',
        rewardCoins: 300,
        rewardXP: 600,
        rewardReputation: 60,
      ),
    ],
  ),
];