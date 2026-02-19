import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final GameProgress progress = await GameProgress.load();
  runApp(KidsColorPopApp(progress: progress));
}

class KidsColorPopApp extends StatelessWidget {
  const KidsColorPopApp({super.key, required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Renk Avi',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2A9D8F),
      ),
      home: HomeScreen(progress: progress),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final int nextLevel = progress.unlockedLevel;
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8EECF5), Color(0xFFFFE5EC)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _HomeHeader(progress: progress),
                    const SizedBox(height: 12),
                    _ProgressStrip(progress: progress),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          _BigActionCard(
                            title: 'Hizli Oyun',
                            subtitle: 'Seviye $nextLevel ile devam et',
                            icon: Icons.play_arrow_rounded,
                            color: const Color(0xFF2A9D8F),
                            onTap: () {
                              _openGame(context, LevelCatalog.levelById(nextLevel), progress);
                            },
                          ),
                          const SizedBox(height: 10),
                          _BigActionCard(
                            title: 'Seviye Haritasi',
                            subtitle: '24 bolumluk macerayi sec',
                            icon: Icons.map_outlined,
                            color: const Color(0xFFE76F51),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => LevelMapScreen(progress: progress),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          _BigActionCard(
                            title: 'Gorevler',
                            subtitle: 'Yildiz ve skor hedeflerini tamamla',
                            icon: Icons.task_alt,
                            color: const Color(0xFF6A4C93),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => MissionsScreen(progress: progress),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          _BigActionCard(
                            title: 'Istatistikler',
                            subtitle: 'Toplam performansini incele',
                            icon: Icons.insights,
                            color: const Color(0xFF264653),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => StatsScreen(progress: progress),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const PermissionsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shield_outlined),
                            label: const Text('Izin Merkezi'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openGame(BuildContext context, LevelConfig level, GameProgress progress) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(config: level, progress: progress),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Renk Avi',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF264653)),
          ),
          SizedBox(height: 6),
          Text(
            'Balonlari yakala, yildizlari topla, yeni bolumleri ac.',
            style: TextStyle(fontSize: 15, color: Color(0xFF1D3557)),
          ),
        ],
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Acilan Seviye',
            value: '${progress.unlockedLevel}/${LevelCatalog.levels.length}',
            color: const Color(0xFFE9C46A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: 'Toplam Yildiz',
            value: '${progress.totalStars}',
            color: const Color(0xFF2A9D8F),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: 'En Iyi Combo',
            value: '${progress.bestComboGlobal}',
            color: const Color(0xFFE76F51),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.18),
      ),
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _BigActionCard extends StatelessWidget {
  const _BigActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.72)]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.24),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelMapScreen extends StatelessWidget {
  const LevelMapScreen({super.key, required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Seviye Haritasi')),
          body: GridView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: LevelCatalog.levels.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final LevelConfig level = LevelCatalog.levels[index];
              final bool unlocked = progress.isLevelUnlocked(level.id);
              final int stars = progress.starsFor(level.id);
              return InkWell(
                onTap: unlocked
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => GameScreen(config: level, progress: progress),
                          ),
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: BoxDecoration(
                    color: unlocked ? Colors.white : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: unlocked ? const Color(0xFF2A9D8F) : Colors.grey.shade400),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('S${level.id}', style: const TextStyle(fontWeight: FontWeight.w900)),
                            Icon(unlocked ? Icons.lock_open : Icons.lock, size: 18),
                          ],
                        ),
                        Text(
                          level.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        _StarsRow(stars: stars),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (int i) {
        return Icon(
          i < stars ? Icons.star : Icons.star_border,
          size: 18,
          color: i < stars ? const Color(0xFFE9C46A) : Colors.grey,
        );
      }),
    );
  }
}

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key, required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    final List<MissionItem> missions = <MissionItem>[
      MissionItem(
        title: 'Yildiz Toplayici',
        description: 'Toplam 20 yildiz kazan',
        progress: progress.totalStars / 20,
      ),
      MissionItem(
        title: 'Bolum Fatihi',
        description: '10 seviye tamamla',
        progress: progress.completedLevels / 10,
      ),
      MissionItem(
        title: 'Combo Ustasi',
        description: 'En az 12 combo yap',
        progress: progress.bestComboGlobal / 12,
      ),
      MissionItem(
        title: 'Skor Canavari',
        description: 'Tek oyunda 500 skor yap',
        progress: progress.highestScore / 500,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Gorevler')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, i) => _MissionCard(item: missions[i]),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: missions.length,
      ),
    );
  }
}

class MissionItem {
  const MissionItem({required this.title, required this.description, required this.progress});

  final String title;
  final String description;
  final double progress;

  bool get completed => progress >= 1;
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.item});

  final MissionItem item;

  @override
  Widget build(BuildContext context) {
    final double p = item.progress.clamp(0, 1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.completed ? const Color(0xFF2A9D8F) : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              Icon(item.completed ? Icons.check_circle : Icons.timelapse, color: item.completed ? Colors.green : Colors.orange),
            ],
          ),
          const SizedBox(height: 4),
          Text(item.description),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: p, minHeight: 10),
          ),
          const SizedBox(height: 4),
          Text('%${(p * 100).toStringAsFixed(0)} tamamlandi'),
        ],
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Istatistikler')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatTile(label: 'Tamamlanan Seviye', value: '${progress.completedLevels}'),
              _StatTile(label: 'Toplam Yildiz', value: '${progress.totalStars}'),
              _StatTile(label: 'En Yuksek Skor', value: '${progress.highestScore}'),
              _StatTile(label: 'En Yuksek Combo', value: '${progress.bestComboGlobal}'),
              _StatTile(label: 'Acilan Son Seviye', value: '${progress.unlockedLevel}'),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.config, required this.progress});

  final LevelConfig config;
  final GameProgress progress;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  static const List<Color> _masterPalette = <Color>[
    Color(0xFFE63946),
    Color(0xFFF4A261),
    Color(0xFFE9C46A),
    Color(0xFF2A9D8F),
    Color(0xFF219EBC),
    Color(0xFF6A4C93),
    Color(0xFFFF006E),
    Color(0xFF00B4D8),
  ];

  late List<Color> _palette;
  final List<Bubble> _bubbles = <Bubble>[];

  Timer? _gameLoop;
  Timer? _spawnLoop;
  Timer? _secondLoop;

  Size _playfieldSize = Size.zero;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _remainingSeconds = 0;
  int _targetTick = 0;
  int _hits = 0;
  int _misses = 0;
  Color _targetColor = const Color(0xFFE63946);

  @override
  void initState() {
    super.initState();
    _palette = _masterPalette.take(widget.config.paletteSize).toList();
    _targetColor = _palette[_random.nextInt(_palette.length)];
    _remainingSeconds = widget.config.durationSeconds;
    _startGame();
  }

  @override
  void dispose() {
    _stopGameLoops();
    super.dispose();
  }

  void _startGame() {
    _gameLoop = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        final List<Bubble> nextList = <Bubble>[];
        for (final Bubble bubble in _bubbles) {
          final Bubble next = bubble.copyWith(y: bubble.y - bubble.speed);
          if (next.y + next.size > 0) {
            nextList.add(next);
          }
        }
        _bubbles
          ..clear()
          ..addAll(nextList);
      });
    });

    _restartSpawnLoop();

    _secondLoop = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _remainingSeconds -= 1;
        _targetTick += 1;
        if (_targetTick % widget.config.colorSwitchEverySec == 0) {
          _pickNextTargetColor();
        }
        if (_remainingSeconds <= 0) {
          _finishGame();
        }
      });
    });
  }

  void _restartSpawnLoop() {
    _spawnLoop?.cancel();
    _spawnLoop = Timer.periodic(Duration(milliseconds: widget.config.baseSpawnMs), (_) {
      if (!mounted) {
        return;
      }
      setState(_spawnBubble);
    });
  }

  void _spawnBubble() {
    if (_playfieldSize.width <= 0 || _playfieldSize.height <= 0) {
      return;
    }

    final double size = 36 + (_random.nextDouble() * 32);
    final double maxX = max(8, _playfieldSize.width - size - 8);
    final double x = 8 + (_random.nextDouble() * (maxX - 8));
    final double scoreBoost = (_score / widget.config.targetScore).clamp(0, 1.4);
    final double speed = widget.config.baseSpeed + (_random.nextDouble() * 1.2) + scoreBoost;

    _bubbles.add(
      Bubble(
        x: x,
        y: _playfieldSize.height + size,
        size: size,
        speed: speed,
        color: _palette[_random.nextInt(_palette.length)],
      ),
    );
  }

  void _onTapPlayfield(TapDownDetails details) {
    final Offset tap = details.localPosition;
    int hitIndex = -1;

    for (int i = _bubbles.length - 1; i >= 0; i--) {
      final Bubble bubble = _bubbles[i];
      final Offset center = Offset(bubble.x + (bubble.size / 2), bubble.y + (bubble.size / 2));
      if ((tap - center).distance <= bubble.size / 2) {
        hitIndex = i;
        break;
      }
    }

    setState(() {
      if (hitIndex == -1) {
        _misses += 1;
        _combo = 0;
        _score = max(0, _score - 3);
        return;
      }

      final Bubble hit = _bubbles.removeAt(hitIndex);
      if (hit.color == _targetColor) {
        _hits += 1;
        _combo += 1;
        _maxCombo = max(_maxCombo, _combo);
        _score += 12 + (_combo * 2);
        HapticFeedback.lightImpact();
        _pickNextTargetColor();
      } else {
        _misses += 1;
        _combo = 0;
        _score = max(0, _score - 8);
        HapticFeedback.selectionClick();
      }
    });
  }

  void _pickNextTargetColor() {
    Color next = _targetColor;
    while (next == _targetColor) {
      next = _palette[_random.nextInt(_palette.length)];
    }
    _targetColor = next;
  }

  void _stopGameLoops() {
    _gameLoop?.cancel();
    _spawnLoop?.cancel();
    _secondLoop?.cancel();
  }

  Future<void> _finishGame() async {
    _stopGameLoops();
    final int total = _hits + _misses;
    final double accuracy = total == 0 ? 0 : _hits / total;
    final LevelOutcome outcome = await widget.progress.completeLevel(
      levelId: widget.config.id,
      score: _score,
      accuracy: accuracy,
      maxCombo: _maxCombo,
      targetScore: widget.config.targetScore,
    );

    if (!mounted) {
      return;
    }

    final bool? goNext = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text('Seviye ${widget.config.id} Tamamlandi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Skor: $_score / Hedef: ${widget.config.targetScore}'),
              Text('Isabet: %${(accuracy * 100).toStringAsFixed(0)}'),
              Text('Maks Combo: $_maxCombo'),
              const SizedBox(height: 8),
              _StarsRow(stars: outcome.stars),
              if (outcome.unlockedNext)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Yeni seviye acildi!', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Ana Menu'),
            ),
            if (widget.config.id < LevelCatalog.levels.length && widget.progress.isLevelUnlocked(widget.config.id + 1))
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sonraki Seviye'),
              ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (goNext == true && widget.config.id < LevelCatalog.levels.length) {
      final LevelConfig nextLevel = LevelCatalog.levelById(widget.config.id + 1);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => GameScreen(config: nextLevel, progress: widget.progress),
        ),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seviye ${widget.config.id}: ${widget.config.name}')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _playfieldSize = Size(constraints.maxWidth, constraints.maxHeight);
          final double totalTap = (_hits + _misses).toDouble();
          final double accuracy = totalTap == 0 ? 0 : _hits / totalTap;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF1CF), Color(0xFFD6FFF6)],
              ),
            ),
            child: Column(
              children: [
                _TopHud(
                  score: _score,
                  combo: _combo,
                  seconds: _remainingSeconds,
                  targetColor: _targetColor,
                  accuracy: accuracy,
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: _onTapPlayfield,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(painter: _SoftBackgroundPainter()),
                          ),
                        ),
                        ..._bubbles.map((Bubble bubble) {
                          return Positioned(
                            left: bubble.x,
                            top: bubble.y,
                            child: _BubbleView(bubble: bubble),
                          );
                        }),
                        Positioned(
                          left: 14,
                          bottom: 14,
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Text('Hedef: ${widget.config.targetScore} skor'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.score,
    required this.combo,
    required this.seconds,
    required this.targetColor,
    required this.accuracy,
  });

  final int score;
  final int combo;
  final int seconds;
  final Color targetColor;
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      color: Colors.white.withValues(alpha: 0.84),
      child: Row(
        children: [
          Expanded(child: _HudChip(label: 'Skor', value: '$score')),
          const SizedBox(width: 8),
          Expanded(child: _HudChip(label: 'Combo', value: 'x$combo')),
          const SizedBox(width: 8),
          Expanded(child: _HudChip(label: 'Sure', value: '$seconds sn')),
          const SizedBox(width: 8),
          Expanded(child: _HudChip(label: 'Isabet', value: '%${(accuracy * 100).toStringAsFixed(0)}')),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: targetColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _BubbleView extends StatelessWidget {
  const _BubbleView({required this.bubble});

  final Bubble bubble;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bubble.size,
      height: bubble.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.2, -0.3),
          colors: [
            Colors.white.withValues(alpha: 0.75),
            bubble.color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: bubble.color.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class Bubble {
  const Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });

  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;

  Bubble copyWith({double? x, double? y, double? size, double? speed, Color? color}) {
    return Bubble(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      speed: speed ?? this.speed,
      color: color ?? this.color,
    );
  }
}

class _SoftBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.24);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), 80, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.35), 110, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 90, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LevelConfig {
  const LevelConfig({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.targetScore,
    required this.baseSpawnMs,
    required this.baseSpeed,
    required this.paletteSize,
    required this.colorSwitchEverySec,
  });

  final int id;
  final String name;
  final int durationSeconds;
  final int targetScore;
  final int baseSpawnMs;
  final double baseSpeed;
  final int paletteSize;
  final int colorSwitchEverySec;
}

class LevelCatalog {
  static final List<LevelConfig> levels = List<LevelConfig>.generate(24, (int i) {
    final int id = i + 1;
    final int zone = (id - 1) ~/ 6;
    return LevelConfig(
      id: id,
      name: _zoneName(zone),
      durationSeconds: 45 + (zone * 5),
      targetScore: 140 + (id * 22),
      baseSpawnMs: max(300, 760 - (id * 18)),
      baseSpeed: 1.2 + (id * 0.06),
      paletteSize: min(8, 4 + zone + (id % 2)),
      colorSwitchEverySec: max(2, 5 - zone),
    );
  });

  static LevelConfig levelById(int id) => levels[id - 1];

  static String _zoneName(int zone) {
    switch (zone) {
      case 0:
        return 'Baslangic';
      case 1:
        return 'Orman';
      case 2:
        return 'Nehir';
      default:
        return 'Galaksi';
    }
  }
}

class LevelOutcome {
  const LevelOutcome({required this.stars, required this.unlockedNext});

  final int stars;
  final bool unlockedNext;
}

class LevelRecord {
  const LevelRecord({required this.bestScore, required this.bestStars, required this.bestCombo});

  final int bestScore;
  final int bestStars;
  final int bestCombo;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bestScore': bestScore,
      'bestStars': bestStars,
      'bestCombo': bestCombo,
    };
  }

  factory LevelRecord.fromJson(Map<String, dynamic> json) {
    return LevelRecord(
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      bestStars: (json['bestStars'] as num?)?.toInt() ?? 0,
      bestCombo: (json['bestCombo'] as num?)?.toInt() ?? 0,
    );
  }
}

class GameProgress extends ChangeNotifier {
  GameProgress({required this.unlockedLevel, required this.records});

  static const String _prefsKey = 'renk_avi_progress_v1';

  int unlockedLevel;
  final Map<int, LevelRecord> records;

  int get totalStars {
    return records.values.fold<int>(0, (int sum, LevelRecord r) => sum + r.bestStars);
  }

  int get completedLevels {
    return records.values.where((LevelRecord r) => r.bestScore > 0).length;
  }

  int get bestComboGlobal {
    int best = 0;
    for (final LevelRecord r in records.values) {
      best = max(best, r.bestCombo);
    }
    return best;
  }

  int get highestScore {
    int best = 0;
    for (final LevelRecord r in records.values) {
      best = max(best, r.bestScore);
    }
    return best;
  }

  int starsFor(int levelId) => records[levelId]?.bestStars ?? 0;

  bool isLevelUnlocked(int levelId) => levelId <= unlockedLevel;

  Future<LevelOutcome> completeLevel({
    required int levelId,
    required int score,
    required double accuracy,
    required int maxCombo,
    required int targetScore,
  }) async {
    final int stars = _calculateStars(score: score, targetScore: targetScore, accuracy: accuracy);
    final LevelRecord previous = records[levelId] ?? const LevelRecord(bestScore: 0, bestStars: 0, bestCombo: 0);
    records[levelId] = LevelRecord(
      bestScore: max(previous.bestScore, score),
      bestStars: max(previous.bestStars, stars),
      bestCombo: max(previous.bestCombo, maxCombo),
    );

    bool unlockedNext = false;
    if (levelId == unlockedLevel && stars > 0 && unlockedLevel < LevelCatalog.levels.length) {
      unlockedLevel += 1;
      unlockedNext = true;
    }

    await save();
    notifyListeners();
    return LevelOutcome(stars: stars, unlockedNext: unlockedNext);
  }

  int _calculateStars({required int score, required int targetScore, required double accuracy}) {
    if (score < targetScore * 0.65) {
      return 0;
    }
    int stars = 1;
    if (score >= targetScore) {
      stars = 2;
    }
    if (score >= (targetScore * 1.25) && accuracy >= 0.72) {
      stars = 3;
    }
    return stars;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'unlockedLevel': unlockedLevel,
      'records': records.map<String, dynamic>((int k, LevelRecord v) => MapEntry<String, dynamic>(k.toString(), v.toJson())),
    };
  }

  Future<void> save() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(toJson()));
    } on MissingPluginException {
      // Plugin not registered yet on current runtime; skip persistence.
    } on PlatformException {
      // Storage channel is temporarily unavailable.
    }
  }

  static Future<GameProgress> load() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return GameProgress(unlockedLevel: 1, records: <int, LevelRecord>{});
    } on PlatformException {
      return GameProgress(unlockedLevel: 1, records: <int, LevelRecord>{});
    }

    final String? raw = prefs.getString(_prefsKey);
    if (raw == null) {
      return GameProgress(unlockedLevel: 1, records: <int, LevelRecord>{});
    }

    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      final int unlocked = (data['unlockedLevel'] as num?)?.toInt() ?? 1;
      final Map<String, dynamic> rawRecords = (data['records'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final Map<int, LevelRecord> parsed = <int, LevelRecord>{};
      for (final MapEntry<String, dynamic> entry in rawRecords.entries) {
        final int? levelId = int.tryParse(entry.key);
        if (levelId != null && entry.value is Map<String, dynamic>) {
          parsed[levelId] = LevelRecord.fromJson(entry.value as Map<String, dynamic>);
        }
      }
      return GameProgress(unlockedLevel: unlocked.clamp(1, LevelCatalog.levels.length), records: parsed);
    } catch (_) {
      return GameProgress(unlockedLevel: 1, records: <int, LevelRecord>{});
    }
  }
}

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final Map<Permission, String> _permissions = <Permission, String>{
    Permission.notification: 'Bildirim',
    Permission.camera: 'Kamera',
    Permission.microphone: 'Mikrofon',
    Permission.photos: 'Fotograflar',
    Permission.locationWhenInUse: 'Konum (Uygulama Acikken)',
    Permission.storage: 'Dosya Depolama (Android)',
  };

  bool _isLoading = false;
  Map<Permission, PermissionStatus> _statuses = <Permission, PermissionStatus>{};

  @override
  void initState() {
    super.initState();
    _refreshStatuses();
  }

  Future<void> _refreshStatuses() async {
    final Map<Permission, PermissionStatus> next = <Permission, PermissionStatus>{};
    for (final Permission permission in _permissions.keys) {
      next[permission] = await permission.status;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _statuses = next;
    });
  }

  Future<void> _requestAll() async {
    setState(() {
      _isLoading = true;
    });

    for (final Permission permission in _permissions.keys) {
      await permission.request();
    }

    await _refreshStatuses();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color _statusColor(PermissionStatus? status) {
    if (status == null) {
      return Colors.grey;
    }
    if (status.isGranted || status.isLimited) {
      return Colors.green;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return Colors.red;
    }
    return Colors.orange;
  }

  String _statusText(PermissionStatus? status) {
    if (status == null) {
      return 'Bilinmiyor';
    }
    if (status.isGranted) {
      return 'Verildi';
    }
    if (status.isLimited) {
      return 'Sinirli';
    }
    if (status.isDenied) {
      return 'Reddedildi';
    }
    if (status.isPermanentlyDenied) {
      return 'Kalici Red';
    }
    if (status.isRestricted) {
      return 'Kisitli';
    }
    if (status.isProvisional) {
      return 'Gecici';
    }
    return status.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izin Merkezi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Yayin oncesi izin kontrolu. Cocuk guvenligi icin gerekmeyen izinleri kapali tutabilirsin.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: _permissions.entries.map((MapEntry<Permission, String> entry) {
                  final PermissionStatus? status = _statuses[entry.key];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.verified_user, color: _statusColor(status)),
                      title: Text(entry.value),
                      subtitle: Text(_statusText(status)),
                    ),
                  );
                }).toList(),
              ),
            ),
            FilledButton.icon(
              onPressed: _isLoading ? null : _requestAll,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_isLoading ? 'Izinler Aliniyor...' : 'Tum Izinleri Iste'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: openAppSettings,
              child: const Text('Sistem Ayarlarini Ac'),
            ),
          ],
        ),
      ),
    );
  }
}
