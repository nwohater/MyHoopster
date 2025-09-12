import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/player.dart';

class GameProvider extends ChangeNotifier {
  Player? _player;
  bool _isLoading = true;
  
  Player? get player => _player;
  bool get isLoading => _isLoading;
  bool get hasPlayer => _player != null;
  
  GameProvider() {
    _loadPlayer();
  }
  
  Future<void> _loadPlayer() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    final playerData = prefs.getString('player_data');
    
    if (playerData != null) {
      try {
        final json = jsonDecode(playerData);
        _player = Player.fromJson(json);
      } catch (e) {
        print('Error loading player: $e');
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> createPlayer(String name) async {
    _player = Player(name: name);
    await _savePlayer();
    notifyListeners();
  }
  
  Future<void> _savePlayer() async {
    if (_player == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final playerData = jsonEncode(_player!.toJson());
    await prefs.setString('player_data', playerData);
  }
  
  void addExperience(int amount) {
    if (_player == null) return;
    
    _player!.addExperience(amount);
    _savePlayer();
    notifyListeners();
  }
  
  void upgradeAttribute(String attribute, int points) {
    if (_player == null) return;
    
    _player!.upgradeAttribute(attribute, points);
    _savePlayer();
    notifyListeners();
  }
  
  void useEnergy(int amount) {
    if (_player == null) return;
    
    _player!.useEnergy(amount);
    _savePlayer();
    notifyListeners();
  }
  
  void restoreEnergy(int amount) {
    if (_player == null) return;
    
    _player!.restoreEnergy(amount);
    _savePlayer();
    notifyListeners();
  }
  
  void restoreFullEnergy() {
    if (_player == null) return;
    
    _player!.energy = _player!.maxEnergy;
    _savePlayer();
    notifyListeners();
  }
  
  void addCoins(int amount) {
    if (_player == null) return;
    
    _player!.coins += amount;
    _savePlayer();
    notifyListeners();
  }
  
  bool spendCoins(int amount) {
    if (_player == null || _player!.coins < amount) return false;
    
    _player!.coins -= amount;
    _savePlayer();
    notifyListeners();
    return true;
  }
  
  void recordMatchResult({
    required bool won,
    required int points,
    int assists = 0,
    int steals = 0,
    int blocks = 0,
  }) {
    if (_player == null) return;
    
    _player!.stats.recordMatch(
      won: won,
      points: points,
      assists: assists,
      steals: steals,
      blocks: blocks,
    );
    
    if (won) {
      _player!.reputation += 10;
      addCoins(50);
      addExperience(100);
    } else {
      _player!.reputation += 3;
      addCoins(20);
      addExperience(50);
    }
    
    _savePlayer();
    notifyListeners();
  }
  
  Future<void> resetPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('player_data');
    _player = null;
    notifyListeners();
  }
}