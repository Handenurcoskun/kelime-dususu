import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/score_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _bestScore = 0;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadBestScore() async {
    final best = await ScoreService.getBestScore();
    if (mounted) setState(() => _bestScore = best);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildLogo(),
              const SizedBox(height: 12),
              Text(
                'Harfler düşüyor, kelimeler senin!',
                style: GoogleFonts.nunito(color: Colors.white38, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (_bestScore > 0)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 60),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A4A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3A3A5A)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 20),
                      const SizedBox(width: 8),
                      Text('En İyi: $_bestScore',
                          style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _scaleAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      ).then((_) => _loadBestScore()),
                      child: Text('OYNA',
                          style: GoogleFonts.nunito(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4)),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Text('v1.0.0', style: GoogleFonts.nunito(color: Colors.white12, fontSize: 12)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['K', 'E', 'L', 'İ', 'M', 'E'].asMap().entries.map((e) {
            return _logoTile(e.value, e.key);
          }).toList(),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['D', 'Ü', 'Ş', 'Ü', 'Ş', 'Ü'].asMap().entries.map((e) {
            return _logoTile(e.value, e.key + 3);
          }).toList(),
        ),
      ],
    );
  }

  Widget _logoTile(String letter, int index) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFD700),
      const Color(0xFFFF6B6B),
    ];
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final offset = (index % 3) * 0.3;
        final anim = Tween<double>(begin: 0, end: 6).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(offset.clamp(0, 1), (offset + 0.5).clamp(0, 1), curve: Curves.easeInOut),
          ),
        );
        return Transform.translate(
          offset: Offset(0, -anim.value),
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(letter,
                  style: GoogleFonts.nunito(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }
}
