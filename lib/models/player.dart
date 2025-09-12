import 'dart:math';

class Player {
  String name;
  int level;
  int experience;
  int skillPoints;
  
  PlayerAttributes attributes;
  PlayerStats stats;
  
  int energy;
  int maxEnergy;
  
  int coins;
  int reputation;
  
  Player({
    required this.name,
    this.level = 1,
    this.experience = 0,
    this.skillPoints = 0,
    PlayerAttributes? attributes,
    PlayerStats? stats,
    this.energy = 100,
    this.maxEnergy = 100,
    this.coins = 100,
    this.reputation = 0,
  }) : attributes = attributes ?? PlayerAttributes(),
       stats = stats ?? PlayerStats();
  
  int get experienceForNextLevel => level * 100;
  
  double get experienceProgress => experience / experienceForNextLevel;
  
  int get overallRating {
    return ((attributes.speed + 
            attributes.shooting + 
            attributes.dribbling + 
            attributes.defense + 
            attributes.stamina) / 5).round();
  }
  
  void addExperience(int amount) {
    experience += amount;
    while (experience >= experienceForNextLevel) {
      experience -= experienceForNextLevel;
      levelUp();
    }
  }
  
  void levelUp() {
    level++;
    skillPoints += 3;
    maxEnergy += 10;
    energy = maxEnergy;
  }
  
  void upgradeAttribute(String attribute, int points) {
    if (skillPoints < points) return;
    
    switch (attribute) {
      case 'speed':
        attributes.speed = min(99, attributes.speed + points);
        break;
      case 'shooting':
        attributes.shooting = min(99, attributes.shooting + points);
        break;
      case 'dribbling':
        attributes.dribbling = min(99, attributes.dribbling + points);
        break;
      case 'defense':
        attributes.defense = min(99, attributes.defense + points);
        break;
      case 'stamina':
        attributes.stamina = min(99, attributes.stamina + points);
        break;
    }
    skillPoints -= points;
  }
  
  void useEnergy(int amount) {
    energy = max(0, energy - amount);
  }
  
  void restoreEnergy(int amount) {
    energy = min(maxEnergy, energy + amount);
  }
  
  bool canTrain() => energy >= 20;
  
  bool canPlayMatch() => energy >= 30;
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'level': level,
    'experience': experience,
    'skillPoints': skillPoints,
    'attributes': attributes.toJson(),
    'stats': stats.toJson(),
    'energy': energy,
    'maxEnergy': maxEnergy,
    'coins': coins,
    'reputation': reputation,
  };
  
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      level: json['level'],
      experience: json['experience'],
      skillPoints: json['skillPoints'],
      attributes: PlayerAttributes.fromJson(json['attributes']),
      stats: PlayerStats.fromJson(json['stats']),
      energy: json['energy'],
      maxEnergy: json['maxEnergy'],
      coins: json['coins'],
      reputation: json['reputation'],
    );
  }
}

class PlayerAttributes {
  int speed;
  int shooting;
  int dribbling;
  int defense;
  int stamina;
  int height;
  
  PlayerAttributes({
    this.speed = 50,
    this.shooting = 50,
    this.dribbling = 50,
    this.defense = 50,
    this.stamina = 50,
    this.height = 180,
  });
  
  Map<String, dynamic> toJson() => {
    'speed': speed,
    'shooting': shooting,
    'dribbling': dribbling,
    'defense': defense,
    'stamina': stamina,
    'height': height,
  };
  
  factory PlayerAttributes.fromJson(Map<String, dynamic> json) {
    return PlayerAttributes(
      speed: json['speed'],
      shooting: json['shooting'],
      dribbling: json['dribbling'],
      defense: json['defense'],
      stamina: json['stamina'],
      height: json['height'],
    );
  }
}

class PlayerStats {
  int matchesPlayed;
  int wins;
  int losses;
  int totalPoints;
  int totalAssists;
  int totalSteals;
  int totalBlocks;
  
  PlayerStats({
    this.matchesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.totalPoints = 0,
    this.totalAssists = 0,
    this.totalSteals = 0,
    this.totalBlocks = 0,
  });
  
  double get winRate => matchesPlayed > 0 ? wins / matchesPlayed : 0.0;
  
  double get pointsPerGame => matchesPlayed > 0 ? totalPoints / matchesPlayed : 0.0;
  
  void recordMatch({
    required bool won,
    required int points,
    int assists = 0,
    int steals = 0,
    int blocks = 0,
  }) {
    matchesPlayed++;
    if (won) {
      wins++;
    } else {
      losses++;
    }
    totalPoints += points;
    totalAssists += assists;
    totalSteals += steals;
    totalBlocks += blocks;
  }
  
  Map<String, dynamic> toJson() => {
    'matchesPlayed': matchesPlayed,
    'wins': wins,
    'losses': losses,
    'totalPoints': totalPoints,
    'totalAssists': totalAssists,
    'totalSteals': totalSteals,
    'totalBlocks': totalBlocks,
  };
  
  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      matchesPlayed: json['matchesPlayed'],
      wins: json['wins'],
      losses: json['losses'],
      totalPoints: json['totalPoints'],
      totalAssists: json['totalAssists'],
      totalSteals: json['totalSteals'],
      totalBlocks: json['totalBlocks'],
    );
  }
}