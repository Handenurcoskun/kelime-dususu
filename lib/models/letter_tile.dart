import 'package:flutter/material.dart';

enum TileState { falling, selected, exploding, landed }

class LetterTile {
  final String letter;
  double x;
  double y;
  double speed;
  TileState state;
  bool isSpecial;

  LetterTile({
    required this.letter,
    required this.x,
    required this.y,
    this.speed = 60,
    this.state = TileState.falling,
    this.isSpecial = false,
  });

  static const double tileSize = 54.0;

  Rect get rect => Rect.fromLTWH(x - tileSize / 2, y - tileSize / 2, tileSize, tileSize);
}
