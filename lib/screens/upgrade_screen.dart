import 'package:flutter/material.dart';
import 'package:galaxy_defender/data/game_save.dart';
import 'package:galaxy_defender/widgets/game_button.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  GameSave save = GameSave.initial();

  @override
  Widget build(BuildContext context) {
    final upgrades = [
      ('Hull Durability', 'hull'),
      ('Shield Strength', 'shield'),
      ('Weapon Damage', 'damage'),
      ('Firing Rate', 'fireRate'),
      ('Movement Speed', 'speed'),
      ('Special Capacity', 'special'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Lab')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Wallet: ${save.credits}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...upgrades.map((entry) {
              final level = save.upgrades[entry.$2] ?? 0;
              return Card(
                child: ListTile(
                  title: Text(entry.$1),
                  subtitle: Text('Level $level'),
                  trailing: GameButton(
                    label: 'Upgrade',
                    onPressed: () {
                      final next = (save.credits >= 150) ? save.copyWith(
                            credits: save.credits - 150,
                            upgrades: {
                              ...save.upgrades,
                              entry.$2: (save.upgrades[entry.$2] ?? 0) + 1,
                            },
                          ) : save;
                      setState(() => save = next);
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
