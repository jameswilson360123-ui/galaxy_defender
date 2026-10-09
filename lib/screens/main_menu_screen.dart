import 'package:flutter/material.dart';
import 'package:galaxy_defender/data/game_save.dart';
import 'package:galaxy_defender/widgets/game_button.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  GameSave _save = GameSave.initial();

  @override
  void initState() {
    super.initState();
    _loadSave();
  }

  Future<void> _loadSave() async {
    final repo = _SaveRepository();
    final loaded = await repo.load();
    if (mounted) {
      setState(() => _save = loaded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050914), Color(0xFF0D1332), Color(0xFF1F1A4A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const Text(
                  'GALAXY DEFENDER',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Astra-X: Mission to Hold the Orion Sector',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(label: 'Best', value: '${_save.bestScore}'),
                    const SizedBox(width: 12),
                    _StatChip(label: 'Credits', value: '${_save.credits}'),
                    const SizedBox(width: 12),
                    _StatChip(label: 'Level', value: '${(_save.bestScore ~/ 1000) + 1}'),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 220,
                  child: GameButton(
                    label: 'Play',
                    primary: true,
                    onPressed: () {
                      Navigator.pushNamed(context, '/gameplay', arguments: _save);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 220,
                  child: GameButton(
                    label: 'Continue',
                    onPressed: () {
                      Navigator.pushNamed(context, '/gameplay', arguments: _save);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _MenuRow(
                  children: [
                    _NavButton(label: 'Hangar', onTap: () => Navigator.pushNamed(context, '/hangar')),
                    _NavButton(label: 'Upgrades', onTap: () => Navigator.pushNamed(context, '/upgrades')),
                    _NavButton(label: 'Settings', onTap: () => Navigator.pushNamed(context, '/settings')),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuRow(
                  children: [
                    _NavButton(label: 'Missions', onTap: () {}),
                    _NavButton(label: 'Achievements', onTap: () {}),
                    _NavButton(label: 'How to Play', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveRepository {
  Future<GameSave> load() async {
    return GameSave.initial();
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .map((child) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: child)))
          .toList(),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GameButton(label: label, onPressed: onTap);
  }
}
