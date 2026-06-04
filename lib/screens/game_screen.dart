import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_controller.dart';
import '../models/letter_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController _controller = GameController();
  Timer? _gameLoop;
  DateTime _lastTick = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _controller.init(size.width, size.height);
      _controller.startGame();
      _startLoop();
    });
  }

  void _startLoop() {
    _lastTick = DateTime.now();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = DateTime.now();
      final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
      _lastTick = now;
      _controller.update(dt);
      if (_controller.status == GameStatus.gameOver) {
        _gameLoop?.cancel();
        _showGameOver();
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Oyun Bitti!',
            style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skorunuz', style: GoogleFonts.nunito(color: Colors.white60, fontSize: 16)),
            Text('${_controller.score}',
                style: GoogleFonts.nunito(color: const Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Seviye ${_controller.level}',
                style: GoogleFonts.nunito(color: Colors.white60, fontSize: 16)),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Ana Menü', style: GoogleFonts.nunito(color: Colors.white60)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _gameLoop?.cancel();
                    _controller.startGame();
                    _startLoop();
                  },
                  child: Text('Tekrar', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              _buildBackground(),
              ..._controller.tiles.map((tile) => _buildTile(tile)),
              _buildTopBar(),
              _buildDropZone(),
              _buildWordBar(),
              if (_controller.status == GameStatus.paused) _buildPauseOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.pause_rounded, color: Colors.white60),
              onPressed: () {
                _gameLoop?.cancel();
                _controller.pauseGame();
              },
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SKOR', style: GoogleFonts.nunito(color: Colors.white38, fontSize: 11, letterSpacing: 2)),
                Text('${_controller.score}',
                    style: GoogleFonts.nunito(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Row(
              children: List.generate(3, (i) {
                return Icon(
                  i < _controller.lives ? Icons.favorite : Icons.favorite_border,
                  color: i < _controller.lives ? const Color(0xFFFF6B6B) : Colors.white24,
                  size: 22,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(LetterTile tile) {
    final isSelected = tile.state == TileState.selected;
    final selIndex = _controller.selected.indexOf(tile);
    return Positioned(
      left: tile.x - LetterTile.tileSize / 2,
      top: tile.y - LetterTile.tileSize / 2,
      child: GestureDetector(
        onTap: () => _controller.selectTile(tile),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: LetterTile.tileSize,
          height: LetterTile.tileSize,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF2A2A4A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFB0ADFF) : const Color(0xFF3A3A5A),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  tile.letter,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isSelected && selIndex >= 0)
                Positioned(
                  top: 3,
                  right: 5,
                  child: Text(
                    '${selIndex + 1}',
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropZone() {
    final bottom = MediaQuery.of(context).size.height - 140;
    return Positioned(
      left: 0,
      right: 0,
      top: bottom,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFFF6B6B).withValues(alpha: 0.6),
              const Color(0xFFFF6B6B).withValues(alpha: 0.6),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xFF1A1A2E),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 12,
          top: 10,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_controller.lastWord.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _controller.lastWordValid
                      ? '${_controller.lastWord} ✓  +${_controller.lastWordScore} puan'
                      : '${_controller.lastWord} — sözlükte yok',
                  style: GoogleFonts.nunito(
                    color: _controller.lastWordValid ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Harflere sırayla dokun → kelime yaz → ✓',
                  style: GoogleFonts.nunito(color: Colors.white24, fontSize: 12),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A4A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _controller.currentWord.length >= 2
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF3A3A5A),
                        width: _controller.currentWord.length >= 2 ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _controller.currentWord.isEmpty ? '_ _ _' : _controller.currentWord,
                        style: GoogleFonts.nunito(
                          color: _controller.currentWord.isEmpty ? Colors.white12 : Colors.white,
                          fontSize: _controller.currentWord.isEmpty ? 18 : 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_controller.currentWord.isNotEmpty) ...[
                  IconButton(
                    onPressed: _controller.clearSelection,
                    icon: const Icon(Icons.close_rounded, color: Color(0xFFFF6B6B)),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A4A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _controller.submitWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      minimumSize: const Size(52, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('DURAKLATILDI',
                style: GoogleFonts.nunito(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                _controller.resumeGame();
                _startLoop();
              },
              child: Text('Devam Et', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
