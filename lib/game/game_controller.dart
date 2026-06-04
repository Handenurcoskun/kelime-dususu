import 'dart:math';
import 'package:flutter/material.dart';
import '../models/letter_tile.dart';
import '../services/word_service.dart';
import '../services/score_service.dart';

enum GameStatus { idle, playing, paused, gameOver }

class GameController extends ChangeNotifier {
  final WordService _wordService = WordService();
  final Random _rng = Random();

  GameStatus status = GameStatus.idle;
  List<LetterTile> tiles = [];
  List<LetterTile> selected = [];
  int score = 0;
  int lives = 3;
  int level = 1;
  String currentWord = '';
  String lastWord = '';
  bool lastWordValid = false;
  int lastWordScore = 0;

  double _screenWidth = 360;
  double _dropZoneBottom = 0;

  static const String _turkishLetters =
      'AAAAAABBCCCÇDDDEEEEEFFGGGĞHHIIIIIIJKKKLLLLMMMNNNNOOÖPPRRRRSSŞŞTTTTUUÜVVYYZ';

  double get _spawnMinX => LetterTile.tileSize;
  double get _spawnMaxX => _screenWidth - LetterTile.tileSize;

  void init(double screenWidth, double screenHeight) {
    _screenWidth = screenWidth;
    _dropZoneBottom = screenHeight - 140;
  }

  Future<void> startGame() async {
    await _wordService.load();
    tiles.clear();
    selected.clear();
    score = 0;
    lives = 3;
    level = 1;
    currentWord = '';
    status = GameStatus.playing;
    _spawnTile();
    notifyListeners();
  }

  void update(double dt) {
    if (status != GameStatus.playing) return;

    final speed = 60.0 + (level - 1) * 10;
    bool needsSpawn = tiles.where((t) => t.state == TileState.falling).length < 4;

    for (final tile in List<LetterTile>.from(tiles)) {
      if (tile.state == TileState.falling) {
        tile.y += speed * dt;
        if (tile.y >= _dropZoneBottom) {
          if (!selected.contains(tile)) {
            _loseLife();
            tiles.remove(tile);
          }
        }
      }
    }

    if (needsSpawn && tiles.where((t) => t.state == TileState.falling).length < 4) {
      _spawnTile();
    }

    if (score >= level * 200) {
      level++;
    }

    notifyListeners();
  }

  void _spawnTile() {
    if (status != GameStatus.playing) return;
    final letter = _turkishLetters[_rng.nextInt(_turkishLetters.length)];
    final x = _spawnMinX + _rng.nextDouble() * (_spawnMaxX - _spawnMinX);
    tiles.add(LetterTile(letter: letter, x: x, y: 0));
  }

  void selectTile(LetterTile tile) {
    if (status != GameStatus.playing) return;
    if (tile.state != TileState.falling && tile.state != TileState.selected) return;
    if (selected.contains(tile)) {
      selected.remove(tile);
      tile.state = TileState.falling;
    } else {
      selected.add(tile);
      tile.state = TileState.selected;
    }
    currentWord = selected.map((t) => t.letter).join();
    notifyListeners();
  }

  void submitWord() {
    if (currentWord.length < 2) return;
    final valid = _wordService.isValid(currentWord);
    lastWord = currentWord;
    lastWordValid = valid;

    if (valid) {
      final points = ScoreService.calculateWordScore(currentWord);
      lastWordScore = points;
      score += points;
      ScoreService.addToTotal(points);
      ScoreService.saveBestScore(score);
      for (final t in selected) {
        tiles.remove(t);
      }
      _spawnTile();
    } else {
      lastWordScore = 0;
      for (final t in selected) {
        t.state = TileState.falling;
      }
    }

    selected.clear();
    currentWord = '';
    notifyListeners();
  }

  void clearSelection() {
    for (final t in selected) {
      t.state = TileState.falling;
    }
    selected.clear();
    currentWord = '';
    notifyListeners();
  }

  void _loseLife() {
    lives--;
    if (lives <= 0) {
      status = GameStatus.gameOver;
      ScoreService.saveBestScore(score);
    }
    notifyListeners();
  }

  void pauseGame() {
    if (status == GameStatus.playing) {
      status = GameStatus.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (status == GameStatus.paused) {
      status = GameStatus.playing;
      notifyListeners();
    }
  }
}
