import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const _keyBest = 'best_score';
  static const _keyTotal = 'total_score';

  static Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBest) ?? 0;
  }

  static Future<void> saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyBest) ?? 0;
    if (score > current) await prefs.setInt(_keyBest, score);
  }

  static Future<int> getTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotal) ?? 0;
  }

  static Future<void> addToTotal(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyTotal) ?? 0;
    await prefs.setInt(_keyTotal, current + score);
  }

  static int calculateWordScore(String word) {
    final base = word.length * 10;
    final bonus = word.length > 4 ? (word.length - 4) * 15 : 0;
    return base + bonus;
  }
}
