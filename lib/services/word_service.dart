import 'package:flutter/services.dart';

class WordService {
  static final WordService _instance = WordService._internal();
  factory WordService() => _instance;
  WordService._internal();

  final Set<String> _words = {};
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/words/turkce_kelimeler.txt');
    for (final line in raw.split('\n')) {
      final w = line.trim().toUpperCase();
      if (w.isNotEmpty) _words.add(w);
    }
    _loaded = true;
  }

  bool isValid(String word) => _words.contains(word.toUpperCase());

  bool isPossiblePrefix(String prefix) {
    final p = prefix.toUpperCase();
    return _words.any((w) => w.startsWith(p));
  }
}
