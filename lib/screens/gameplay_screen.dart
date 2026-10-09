import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:galaxy_defender/data/game_save.dart';
import 'package:galaxy_defender/game/galaxy_defender_game.dart';
import 'package:galaxy_defender/widgets/game_button.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key, required this.save});

  final GameSave save;

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final GalaxyDefenderGame _game;

  @override
  void initState() {
    super.initState();
    _game = GalaxyDefenderGame(
      save: widget.save,
      onGameOver: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mission failed. Retry from the menu.')),
        );
      },
      onGameWon: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sector cleared! Victory achieved.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          _game.movePlayerBy(details.delta.dx, details.delta.dy);
        },
        onTap: () {
          _game.triggerSpecial();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: GameWidget(game: _game),
            ),
            Positioned(
              top: 24,
              left: 16,
              right: 16,
              child: ValueListenableBuilder<GameStats>(
                valueListenable: _game.stats,
                builder: (context, stats, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: _HudCard(
                          label: 'Score',
                          value: '${stats.score}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HudCard(
                          label: 'Wave',
                          value: '${stats.wave}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HudCard(
                          label: 'Lives',
                          value: '${stats.lives}',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: ValueListenableBuilder<GameStats>(
                valueListenable: _game.stats,
                builder: (context, stats, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: _BarCard(
                          label: 'Hull',
                          value: stats.health,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _BarCard(
                          label: 'Shield',
                          value: stats.shield,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              top: 80,
              right: 16,
              child: GameButton(
                label: 'Pause',
                onPressed: () {
                  _game.pause();
                },
              ),
            ),
            Positioned(
              bottom: 110,
              right: 16,
              child: GameButton(
                label: 'Pulse',
                onPressed: () => _game.triggerSpecial(),
                primary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudCard extends StatelessWidget {
  const _HudCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BarCard extends StatelessWidget {
  const _BarCard({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: (value / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
